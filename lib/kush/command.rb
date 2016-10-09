require 'rbconfig'

module Kush
  class Command

    attr_reader :command, :args, :kind, :process
    attr_reader :redirection, :env

    def initialize(string, input: $stdin, output: $stdout, error: $stderr, env: {})
      @string = string
      @argv = string.squeeze(' ').chomp.split(' ')
      @command, *@args = *@argv
      @env = env
      @kind = lookup_kind(@command)
      @redirection = {
        in: input,
        out: output,
        err: error
      }
      @process = create!
    end

    def spawn!
      pid = @process.call
      Process.wait(pid) if program?
      Builtin::History.add(@string) if $? == 0 && Builtin.enabled?(:history)
    end

    private

    def create!
      case
      when builtin?
        Shell.debug 'Kind: builtin'
        proc { Builtin.execute!(@command.to_sym, @args) }
      when program?
        Shell.debug 'Kind: program'
        proc { Process.spawn(@env, *@argv, @redirection) }
      else
        Shell.debug 'Kind: ruby'
        proc { puts eval(@string.chomp) }
      end
    end

    def executable_in_path?(command)
      @env['PATH'].split(':').each do |path|
        file = "#{path}/#{command}"
        found = File.exist?(file) && File.executable?(file)
        Shell.debug("Found: #{file}") if found
        return true if found
      end
      false
    end

    def lookup_kind(command)
      if Builtin.exist?(command)
        :builtin
      elsif executable_in_path?(command)
        :program
      else
        :ruby
      end
    end

    def ruby
      RbConfig::CONFIG['RUBY_EXEC_PREFIX'] + '/ruby'
    end

    def ruby?
      kind == :ruby
    end

    def program?
      kind == :program
    end

    def builtin?
      kind == :builtin
    end
  end
end
