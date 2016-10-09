module Kush
  module Builtin
    module Setenv
      extend self

      def self.execute!(args)
        key, value = args.split('=')
        ENV[key] = value
      end
    end
  end
end
