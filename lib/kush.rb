require 'io/console'
require 'rainbow/ext/string'
require 'shellwords'
require 'set'

require_relative 'kush/command'
require_relative 'kush/line'
require_relative 'kush/keycodes'
require_relative 'kush/builtin'

module Kush
  class Shell

    include Kush::Keycodes

    extend Builtin

    attr_accessor :prompt, :history

    VERBOSE = true
    DEBUG = true
    DEEP_DEBUG = true

    PS1 = '$DIR'.color(:white) + ' $LAMBDA '

    PROMPT_VARS = {
      CWD: -> { Dir.pwd },
      DIR: -> { File.basename(Dir.getwd) },
      LAMBDA: -> { λ = 'λ'.color(:cyan); λ = λ.underline if $safe; λ }
    }

    CONFIG = {
      rc: '.kushrc',
      history: '.kush_history',
      jumper: '.kush_jumpdb'
    }

    def initialize
      Builtin.load!
      $safe = false
      reset_input
      set_traps!
      prompt!
      repl
    end

    def repl
      loop do
        read!
        evaluate(@input) if @input.end_with?(KEY_CR)
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

    def evaluate(string)
      return if string.chomp.empty?
      Line.new(string).execute!
    #   @command, *@args = *line.split(' ')
    #   unless @command.empty?
    #     if     builtin?(@command)    then builtin!(@command, @args)
    #     elsif  ruby?(line)           then ruby!(line)
    #     else   execute!(line) unless $safe
    #     end
    #   end
    # rescue NameError => exception
    #   $safe ? handle_exception(exception) : execute!(@line)
    # rescue StandardError, SyntaxError => exception
    #   handle_exception(exception, @line)
    ensure
      reset_input
      Builtin::History.reset_position
      prompt!
    end

    # def ruby?(line)
    #   !line.strip.start_with?('/')
    # end

    # def ruby!(line)
    #   line = line.strip.chomp
    #   puts eval(line)
    #   Builtin::History.add(line) if $? == 0
    # end

    # def execute!(line)
    #   line = line.strip.chomp
    #   pid = fork do
    #     begin
    #       exec line
    #     rescue SystemCallError => exception
    #       handle_exception(exception, @command)
    #       exit 1
    #     end
    #   end
    #   Process.wait(pid)
    #   Builtin::History.add(line) if $? == 0
    # end

    # def builtin!(builtin, args)
    #   Builtin.execute!(builtin.to_sym, args)
    # end
    #
    # def builtin?(builtin)
    #   Builtin.exist?(builtin.to_sym) && Builtin.enabled?(builtin.to_sym)
    # end

    def handle_exception(exception, command=nil)
      # message = begin
      #   case exception
      #   when Errno::ENOENT then "command not found: #{command}"
      #   end
      # end
      puts format('kush: %s', exception.message).color(:red)
      puts exception.backtrace if VERBOSE
    end

    def self.method_missing(method_sym, *arguments, &block)
      puts 'method missing!'
      raise NotImplementedError
    end

    def format_prompt!
      @prompt = PS1.dup
      PROMPT_VARS.each do |k, v|
        @prompt.gsub! "$#{k}", v.respond_to?(:call) ? v.call : v
      end
    end

    def set_traps!
      Signal.trap('INT') { Shell.quit! }
    end

    def handle(input)
      case input
      when KEY_ESC
        handle_escape(input)
      when KEY_CR
        @input << input
        puts
      when KEY_ETX
        reset_input
        puts
        prompt!
      when KEY_EOT
        Shell.quit!
      when KEY_DEL
        erase unless @input.empty?
      when KEY_TAB
        write_line Completion.complete_all(@input).first unless @input.empty?
      when GLYPH_DOT, GLYPH_LSAQUO, GLYPH_RSAQUO, GLYPH_LAQUO, GLYPH_RAQUO # IO redirection
        print input.color(:red)
        @input << input
      else # Regular printable
        print input
        @input << input
      end
      input
    end

    def handle_escape(input)
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
      case input
      when ANSI_UP
        write_input Builtin::History.navigate(:up)
      when ANSI_DOWN
        write_input Builtin::History.navigate(:down)
      end
    end

    def erase(n=1)
      n.times { @input.chop! }
      $stdout.print ("\b" * n) + (" " * n) + ("\b" * n);
    end

    def erase_input
      erase @input.size
    end

    def reset_input
      @input = ""
    end

    def write_input(string)
      return unless string
      erase_input
      @input = string.chomp
      print @input
    end

    def self.deep_debug(what)
      STDERR.print info(what, :red) if DEEP_DEBUG
    end

    def self.debug(what)
      STDERR.print info(what, :yellow) if DEBUG
    end

    def self.toggle_safe!
      $safe = !$safe
    end

    def self.info(text, color=:cyan)
      puts Array(text).map { |t| format("%s %s", "#{GLYPH_RANGLE * 2}".color(color), t.to_s.chomp) }
    end

    def self.quit!
      Builtin::Jumper.save!(CONFIG[:jumper])
      Builtin::History.save!(CONFIG[:history])
      STDOUT.flush
      STDERR.flush
      puts
      puts 'Quitting...' if VERBOSE
      exit
    end
  end
end
