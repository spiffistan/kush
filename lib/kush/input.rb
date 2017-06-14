require_relative 'keycodes'
require_relative 'glyphs'
require_relative 'cursor'
require_relative 'refinements/string_extensions'

module Kush
  module Input

    include  Keycodes
    include  Glyphs
    extend   Cursor
    using    Refinements::StringExtensions

    def self.buffer
      @@buffer ||= String.new
    end

    def self.position
      @@position ||= 0
    end

    def self.read!
      STDIN.echo = false
      STDIN.raw!
      char = STDIN.getc.chr
    ensure
      STDIN.echo = true
      STDIN.cooked!
      handle char
    end

    def self.handle(char)
      case char
      when KEY_ESC
        handle_escape(char)
      when KEY_CR
        reposition!
        eat! char
        writeln
      when KEY_ETX
        reset!
        writeln '^C'.color(:purple).italic
        prompt!
      when KEY_EOT
        writeln '^D'.color(:purple).italic
        Shell.quit!
      when KEY_DEL
        erase unless min? || buffer.empty?
      when KEY_TAB
        rewrite! Builtin::Completion.complete_all(buffer).first unless buffer.empty?
      when GLYPH_BULLET, GLYPH_LSAQUO, GLYPH_RSAQUO, GLYPH_LAQUO, GLYPH_RAQUO # IO redirection
        write char.color(:cyan).bright
        eat! char
      when GLYPH_TILDE # Magic characters
        write char.color(:blue).bright
        eat! char
      else # Regular printable
        write char
        eat! char
      end
    end

    def self.handle_escape(char)
      string = char
      string << STDIN.read_nonblock(3) rescue nil
      string << STDIN.read_nonblock(2) rescue nil
      case string
      when ANSI_UP
        rewrite! Builtin::History.navigate(:up) if Builtin.enabled?(:hist)
      when ANSI_DOWN
        rewrite! Builtin::History.navigate(:down) if Builtin.enabled?(:hist)
      when ANSI_BACK
        unless min?
          write ANSI_BACK
          decr!
        end
      when ANSI_FORWARD
        unless max?
          write ANSI_FORWARD
          incr!
        end
      end
    end

    def self.erase(n=1)
      n.times { erase_at(position-1) }
      write ("\b" * n) + (" " * n) + ("\b" * n)
      write @@buffer[position..-1]
      # write "\b \b"
    end

    def self.erase!
      erase buffer.size
    end

    def self.write!
      write buffer
    end

    def self.writeln!
      writeln buffer
    end

    def self.erase_at(pos)
      @@buffer = @@buffer.maulin!(pos)
      # redraw!
      # rewrite!
    end

    def self.reset!
      @@buffer = String.new
      @@position = 0
    end

    def self.complete?
      buffer.end_with?(KEY_CR)
    end

    private

    def self.eat!(char)
      if max?
        @@buffer << char
        incr!
      else
        @@buffer = @@buffer.insert(position, char)
      end
    end

    def self.max?
      @@position >= @@buffer.size
    end

    def self.min?
      @@position <= 0
    end

    def self.incr!
      @@position += 1 unless max?
    end

    def self.decr!
      @@position -= 1 unless min?
    end

    def self.rewind!
      @@position = 0
    end

    def self.reposition!
      @@position = @@buffer.chomp.size
    end

    def self.write(string)
      STDOUT.print string
    end

    def self.writeln(string=nil)
      STDOUT.puts string
      rewind!
    end

    def self.redraw!
      write ANSI_CUB(position)
      write ANSI_CLEAR_EOL
      write @@buffer
      write ANSI_CUF(position)
    end

    def self.rewrite!(string)
      return unless string
      erase!
      @@buffer = string.chomp
      reposition!
      write!
    end
  end
end
