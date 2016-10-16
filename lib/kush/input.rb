require_relative 'keycodes'
require_relative 'glyphs'

module Kush
  module Input

    include  Keycodes
    include  Glyphs

    def self.current
      @@current ||= ''
    end

    def self.handle(char)
      case char
      when KEY_ESC
        handle_escape(char)
      when KEY_CR
        current << char
        writeln
      when KEY_ETX
        reset!
        writeln '^C'.color(:purple).italic
        prompt!
      when KEY_EOT
        writeln '^D'.color(:purple).italic
        Shell.quit!
      when KEY_DEL
        erase unless current.empty?
      when KEY_TAB
        rewrite! Builtin::Completion.complete_all(current).first unless current.empty?
      when GLYPH_BULLET, GLYPH_LSAQUO, GLYPH_RSAQUO, GLYPH_LAQUO, GLYPH_RAQUO # IO redirection
        write char.color(:cyan).bright
        current << char
      when GLYPH_TILDE # Magic characters
        write char.color(:blue).bright
        current << char
      else # Regular printable
        write char
        current << char
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
      end
    end

    def self.erase(n=1)
      n.times { current.chop! }
      write ("\b" * n) + (" " * n) + ("\b" * n);
    end

    def self.erase!
      erase current.size
    end

    def self.write!
      write current
    end

    def self.writeln!
      writeln current
    end

    def self.reset!
      @@current = ''
    end

    def self.complete?
      current.end_with?(KEY_CR)
    end

    private

    def self.write(string)
      STDOUT.print string
    end

    def self.writeln(string=nil)
      STDOUT.puts string
    end

    def self.rewrite!(string)
      return unless string
      erase!
      @@current = string.chomp
      write!
    end
  end
end
