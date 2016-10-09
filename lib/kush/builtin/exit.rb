module Kush
  module Builtin
    module Exit
      extend self
      def self.execute!(code = 0)
        exit code.to_i
      end
    end
  end
end
