require 'rbconfig'
require 'shellwords'

module Kush
  class Command

    GLOBBABLE = %w(* ** { } [ ] ? \\) # NOTE: Slash is escaped

    MAGIC = {
      '~' => ENV['HOME']
    }

    attr_reader :command, :args, :kind, :process
    attr_reader :redirection, :env

    def initialize(string, input: $stdin, output: $stdout, error: $stderr, env: {})

      @env = env
      @redirection = { in: input, out: output, err: error }
      @string = string
      @kind = lookup_kind(string.split(' ')[0])
      @argv = *Command.clean(string).shellsplit

      case
      when builtin?
        magic!
      when executable?
        alias!
        glob!
        magic!
      end

      @process = create!
    end

    def spawn!
      Shell.debug 'Result: '.bright + @argv.join(' ')
      pid = @process.call
      Process.wait(pid) if executable?
      Builtin::History.add(@string) if $? == 0 && Builtin.enabled?(:history) || !executable?
    end

    private # __________________________________________________________________

    # Swap the command with the aliased command if found
    def alias!
      if Builtin.enabled?(:alias) && Builtin::Alias.exist?(@argv[0])
        command = @argv.shift
        @argv.unshift(*Builtin::Alias[command].split(' '))
      end
    end

    # Swaps the globbable elements with the globbed results, flattening the result
    def glob!
      args_only do
        @argv.map! { |arg| GLOBBABLE.any? { |g| arg.include?(g) } ? Dir.glob(arg) : arg }.flatten!
      end
    end

    def magic!
      args_only do
        @argv.map! { |arg| arg.chars.map! { magic?(arg) ? MAGIC[arg] : arg }.first }
      end
    end

    def self.clean(string)
      string.squeeze(' ').chomp
    end

    def magic?(char)
      MAGIC.keys.include?(char)
    end

    def args_only
      command = @argv.shift
      yield
      @argv.unshift(command)
    end

    def create!
      case
      when builtin?
        Shell.debug 'Kind: builtin'
        proc { Builtin.builtin!(*@argv) }
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
        return true if File.exist?(file) && File.executable?(file)
      end
      false
    end

    def lookup_kind(command)
      if Builtin.active?(command)
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
