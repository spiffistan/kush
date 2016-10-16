module Kush
  module BuiltinUtils

    class BuiltinError < StandardError; end

    def botch!(message)
      fail BuiltinError, message
    end
  end
end
