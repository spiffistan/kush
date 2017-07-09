require 'ostruct'

module Kush

  DEFAULTS = {
    verbose: true,
    debug: true,
    deep_debug: true,
    safety: false,
    backtrace: true,
    suppress_warnings: false,
    history_lines: 100
  }.freeze

  Config = OpenStruct.new(DEFAULTS)
end
