require_relative 'keycodes'

module Kush
  module Cursor

    include Keycodes

    def ANSI_CUP(row, col)
      KEY_ESC + '[' + row + ';' + col + 'H'
    end

    def ANSI_CUB(n)
      KEY_ESC + '[' + n.to_s + 'D'
    end

    def ANSI_CUF(n)
      KEY_ESC + '[' + n.to_s + 'C'
    end
  end
end
