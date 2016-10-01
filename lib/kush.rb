require 'io/console'
require 'ansi'
require 'rainbow/ext/string'
require 'shellwords'

require_relative 'keycodes'
require_relative 'history'
require_relative 'completion'

module Kush
  class Shell

    include Kush::Keycodes

    attr_accessor :line, :prompt, :history

    VERBOSE = false

    PS1 = '$DIR ' + 'λ '.color(:cyan)

    BUILTINS = {
      cd:   ->(directory = ENV['HOME']) { Dir.chdir(directory) },
      exit: ->(code = 0) { exit(code.to_i) },
      exec: ->(*command) { exec *command },
      set:  ->(args) { key, value = args.split('='); ENV[key] = value },
      hist: :print_history,
      quit: :quit!
    }

    PROMPT_VARS = {
      CWD: -> { Dir.pwd },
      DIR: -> { File.basename(Dir.getwd) }
    }

    CONFIG = {
      history: '.kush_history'
    }

    def initialize
      @history = History.new
      reset_line
      set_traps!
      prompt!
      repl
    end

    def repl
      loop do
        read!
        evaluate parse(line) if line.end_with?("\r")
      end
    rescue StandardError => exception
      handle_exception(exception)
      repl
    end

    def prompt!
      format_prompt!
      print @prompt
    end

    def read!
      STDIN.echo = false
      STDIN.raw!
      input = STDIN.getc.chr
    ensure
      STDIN.echo = true
      STDIN.cooked!
      handle input
    end

    def parse(line)
      command, *args = *line.split(' ')
      Line[command, args]
    end

    def evaluate(parsed)
      case parsed
      when Line[String, Array]
        if     builtin?(parsed.command)  then builtin!(parsed.command, parsed.args)
        elsif  ruby?(parsed.command)     then ruby!(parsed.command)
        else   execute!(line)
        end
      else
        # NOOP
      end
    ensure
      reset_line
      history.reset_position
      prompt!
    end

    def execute!(command)
      @command = command # Remember this
      pid = fork do
        begin
          exec line.strip.chomp
        rescue SystemCallError => exception
          handle_exception(exception)
          exit 1
        end
      end
      Process.wait(pid)
      history << command.strip.chomp if $? == 0
    end

    def ruby?(word)
      word.start_with?(':') || word.start_with?('·')
    end

    def ruby!(ruby)
      pid = fork do
        begin
          result = eval(ruby[1..-1].chomp) # Chop first char, remove newline
          puts result if result.is_a?(String)
        rescue StandardError => exception
          handle_exception(exception)
        end
      end
      Process.wait(pid)
      history << ruby.chomp if $? == 0
    end

    def builtin?(word)
      BUILTINS.has_key?(word.to_sym)
    end

    def builtin!(builtin, args)
      BUILTINS[builtin.to_sym].respond_to?(:call) ? BUILTINS[builtin.to_sym].call(*args) : self.send(BUILTINS[builtin.to_sym], *args)
    end

    def handle_exception(exception)
      message = begin
        case exception
        when Errno::ENOENT then "command not found: #{@command}"
        end
      end
      puts format('kush: %s', message || exception.message).color(:red)
      puts exception.backtrace if VERBOSE
    end

    def format_prompt!
      @prompt = PS1.dup
      PROMPT_VARS.each do |k, v|
        @prompt.gsub! "$#{k}", v.respond_to?(:call) ? v.call : v
      end
    end

    def set_traps!
      Signal.trap('INT') { quit }
    end

    def handle(input)
      case input
      when KEY_ESCAPE
        handle_escape(input)
      when KEY_RETURN
        @line << input
        puts
      when KEY_CTRL_C
        quit!
      when KEY_BACKSPACE
        erase unless @line.empty?
      when KEY_TAB
        write_line Kush::Completion.complete_all(@line).first unless @line.empty?
      else # Printable
        $stdout.print input
        @line << input
      end
      input
    end

    def handle_escape(input)
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
      case input
      when KEY_UP
        write_line history.navigate(:up)
      when KEY_DOWN
        write_line history.navigate(:down)
      end
    end

    def erase(n=1)
      n.times { @line.chop! }
      $stdout.print ("\b" * n) + (" " * n) + ("\b" * n);
    end

    def reset_line
      @line = ""
    end

    def erase_line
      erase @line.size
    end

    def write_line(string)
      return unless string
      erase_line
      @line = string.chomp
      print @line
    end

    def print_history
      puts history.list.last(10000)
    end

    def quit!
      puts # Explicit newline
      puts 'Quitting...' if VERBOSE
      exit
    end

    def debug(what)
      $stderr.puts what
    end
  end


  class Line
    attr_reader :command, :args

    def self.[](command, args)
      Line.new(command, args)
    end

    def initialize(command, args)
      @command, @args = command, args
    end

    def ===(other)
      command === other.command && args === other.args
    end
  end
end

Kush::Shell.new
