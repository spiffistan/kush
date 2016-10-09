module Kush
  module Keycodes

    GLYPH_DOT = '·'
    GLYPH_BULLET = '•'
    GLYPH_LSAQUO = '‹'
    GLYPH_RSAQUO = '›'
    GLYPH_LAQUO = '«'
    GLYPH_RAQUO = '»'
    GLYPH_BAR = '¦'
    GLYPH_LANGLE = '⟨'
    GLYPH_RANGLE = '⟩'

    ASCII_SPECIALS = {
      NUL: 0x00, # Null
      SOH: 0x01, # Start of heading
      STX: 0x02, # Start of text
      ETX: 0x03, # End of text - typically CTRL-C
      EOT: 0x04, # End of transmission - typically CTRL-D
      ENQ: 0x05, # Enquiry
      ACK: 0x06, # Acknowledge
      BEL: 0x07, # Bell
       BS: 0x08, # Backspace
      TAB: 0x09, # Horizontal tab
       LF: 0x0A, # Line feed
       VT: 0x0B, # Vertical tab
       FF: 0x0C, # Form feed
       CR: 0x0D, # Carriage return
       SO: 0x0E, # Shift out
       SI: 0x0F, # Shift in
      DLE: 0x10, # Data-link escape
      DC1: 0x11, # Device control 1
      DC2: 0x12, # Device control 2
      DC3: 0x13, # Device control 3
      DC4: 0x14, # Device control 4
      NAK: 0x15, # Negative acknowledge
      SYN: 0x16, # Synchronous idle
      ETB: 0x17, # End of transmission block
      CAN: 0x18, # Cancel
       EM: 0x19, # End of medium
      SUB: 0x1A, # Substitute
      ESC: 0x1B, # ESC
       FS: 0x1C, # File separator
       GS: 0x1D, # Group separator
       RS: 0x1E, # Record separator
       US: 0x1F, # Unit separator
       # ...
      DEL: 0x7F  # Delete
    }.freeze
    private_constant :ASCII_SPECIALS

    # Loops through the previous hash and sets convenience key constants
    # of the form KEY_ESC, KEY_CR, etc.
    ASCII_SPECIALS.each do |k,v|
      const_set "KEY_#{k}", v.chr
    end

    ANSI_ESCAPES = {
      UP:           '[A',     # Move the cursor up
      DOWN:         '[B',     # Move the cursor down
      FORWARD:      '[C',     # Move the cursor forward
      BACK:         '[D',     # Move the cursor back
      SAVE:         '[s',     # Save current cursor positon
      RESTORE:      '[u',     # Restore saved cursor positon
      CLEAR_EOL:    '[K',     # Clear to the end of the current line
      CLEAR_RIGHT:  '[0K',    # Clear to the end of the current line
      CLEAR_LEFT:   '[1K',    # Clear to the start of the current line
      CLEAR_LINE:   '[2K',    # Clear the entire current line
      CLEAR_SCREEN: '[2J',    # Clear the screen and move cursor to home
      CURSOR_HIDE:  '[?25l',  # Hide the cursor
      CURSOR_SHOW:  '[?25h'   # Show the cursor
    }.freeze
    private_constant :ANSI_ESCAPES

    # Loops through the previous hash and sets convenience key constants
    # of the form ANSI_UP, ANSI_CLEAR_EOL, etc.
    ANSI_ESCAPES.each do |k,v|
      const_set "ANSI_#{k}", KEY_ESC + v
    end

  end
end
