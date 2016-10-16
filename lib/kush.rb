require 'io/console'
require 'rainbow/ext/string'
require 'shellwords'
require 'set'

require_relative 'kush/globals'
require_relative 'kush/utils'
require_relative 'kush/command'
require_relative 'kush/prompt'
require_relative 'kush/line'
require_relative 'kush/keycodes'
require_relative 'kush/refinements/string_extensions'
require_relative 'kush/refinements/hash_extensions'
require_relative 'kush/builtin_utils'
require_relative 'kush/builtin'

module Kush
  class Shell

    using    Refinements::HashExtensions

    extend   Utils
    extend   Builtin
    extend   Prompt

    include  Globals
    include  Keycodes

    attr_accessor :history

    CONFIG = {
      rc: '.kushrc',
      history: '.kush_history',
      jumper: '.kush_jumpdb'
    }

    def initialize
      Builtin.load_all!(CONFIG)
      reset_input
      set_traps!
      prompt!
      repl
    end

    # The main loop: reads a single character per iteration and evaluates every
    # line ending with carriage return.
    def repl
      loop do
        read!
        evaluate(@input) if @input.end_with?(KEY_CR)
      end
    rescue StandardError => exception
      handle_exception(exception)
      prompt!
      repl
    end

    def prompt!
      print Prompt.formatted!
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
    ensure
      reset_input
      Builtin::History.reset_position
      prompt!
    end

    def set_traps!
      # NOOP
    end

    def handle_exception(exception)
      puts # Newline
      puts exception.message.color(:red)
      puts exception.backtrace if $backtrace
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
        puts '^C'.color(:purple).italic
        prompt!
      when KEY_EOT
        puts '^D'.color(:purple).italic
        Shell.quit!
      when GLYPH_TILDE
        print input.color(:blue).bright
        @input << input
      when KEY_DEL
        erase unless @input.empty?
      when KEY_TAB
        write_input Builtin::Completion.complete_all(@input).first unless @input.empty?
      when GLYPH_BULLET, GLYPH_LSAQUO, GLYPH_RSAQUO, GLYPH_LAQUO, GLYPH_RAQUO # IO redirection
        print input.color(:cyan)
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

    def self.toggle_safe!
      $safe = !$safe
    end

    def self.unsafe?
      !$safe
    end

    def self.title!
      OSC_LEADER + '6' + ';' + 'file://' + Dir.pwd + KEY_BEL
    end

    def self.quit!
      Builtin::Jumper.save!(CONFIG[:jumper])
      Builtin::History.save!(CONFIG[:history])
      STDOUT.flush
      STDERR.flush
      puts 'Quitting...' if $debug
      exit
    end
  end
end
