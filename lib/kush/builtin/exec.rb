module Kush
  module Builtin
    module Exec
      extend self
      def self.execute!(*command)
        exec *command
      end
    end
  end
end
