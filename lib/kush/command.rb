require 'rbconfig'
require 'shellwords'

module Kush
  class Command

    attr_reader :command, :args, :kind, :process
    attr_reader :redirection, :env

    def initialize(string, input: $stdin, output: $stdout, error: $stderr, env: {})
      @env = env
      @redirection = { in: input, out: output, err: error }
      @string = string
      @kind = lookup_kind(string.split(' ')[0])

      case
      when builtin?
        @command, *@args = *Command.clean(string).shellsplit
      when executable?
        @argv = *Command.clean(string).shellsplit
        # Swap the command with the aliased command if found
        if Builtin.enabled?(:alias) && Builtin::Alias.exist?(@argv[0])
          command = @argv.shift
          @argv.unshift(*Builtin::Alias[command].split(' '))
        end
      end

      @process = create!
    end

    def spawn!
      pid = @process.call
      Process.wait(pid) if executable?
      Builtin::History.add(@string) if $? == 0 && Builtin.enabled?(:history) || !executable?
    end

    def self.clean(string)
      string.squeeze(' ').chomp
    end

    private

    def create!
      case
      when builtin?
        Shell.debug 'Kind: builtin'
        proc { Builtin.execute!(@command.to_sym, @args) }
      when Shell.unsafe? && executable?
        Shell.debug 'Kind: executable'
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
        # Shell.deep_debug("Checking: #{file}")
        # Shell.debug("Found: #{file}") if found
        return true if found
      end
      # Shell.deep_debug("Not found: #{command}")
      false
    end

    def lookup_kind(command)
      if Builtin.exist?(command)
        :builtin
      elsif Shell.unsafe? && executable_in_path?(command)
        :executable
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

    def executable?
      kind == :executable
    end

    def builtin?
      kind == :builtin
    end
  end
end
