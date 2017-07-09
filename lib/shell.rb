require 'io/console'
require 'rainbow/ext/string'
require 'shellwords'
require 'set'

require_relative 'kush/config'
require_relative 'kush/utils'
require_relative 'kush/command'
require_relative 'kush/input'
require_relative 'kush/prompt'
require_relative 'kush/line'
require_relative 'kush/refinements/string_extensions'
require_relative 'kush/refinements/hash_extensions'
require_relative 'kush/builtin_utils'
require_relative 'kush/builtin'

module Kush
  class Shell

    extend   Utils
    extend   Builtin
    extend   Prompt

    include  Keycodes

    FILES = {
      rc: '.kushrc',
      history: '.kush_history',
      jumper: '.kush_jumpdb'
    }

    def initialize
      Builtin.load_all!(FILES)
      Input.reset!
      set_traps!
      prompt!
      repl
    end

    # The main loop: reads a single character per iteration and evaluates every
    # line ending with carriage return.
    def repl
      loop do
        Input.read!
        evaluate(Input.buffer) if Input.complete?
      end
    rescue StandardError, SyntaxError => exception
      handle_exception(exception)
    ensure
      prompt!
      repl
    end

    def prompt!
      Input.write Prompt.formatted!
    end

    def evaluate(string)
      return if string.chomp.empty?
      Line.new(string).execute!
    ensure
      Input.reset!
      Builtin::History.reset_position
      prompt!
    end

    def set_traps!
      # NOOP
    end

    def handle_exception(exception)
      case exception
      when SyntaxError
      when StandardError
      else
      end
      puts # Newline
      puts exception.message.color(:red)
      puts exception.backtrace if Config.backtrace
    end

    def self.toggle_safety!
      Config.safety = !Config.safety
    end

    def self.unsafe?
      !Config.safety
    end

    def self.title!
      OSC_LEADER + '7' + ';' + 'file://' + Dir.pwd + KEY_BEL
      OSC_LEADER + '6' + ';' + 'file://' + Dir.pwd + KEY_BEL
    end

    def self.quit!
      Builtin::Jumper.save!(FILES[:jumper])
      Builtin::History.save!(FILES[:history])
      STDOUT.flush
      STDERR.flush
      puts 'Quitting...' if Config.verbose
      exit
    end
  end
end
