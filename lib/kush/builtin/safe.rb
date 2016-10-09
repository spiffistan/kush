module Kush
  module Builtins
    module Safe
      extend self

      def self.execute!
        Shell.toggle_safe!
        Shell.info "Safety #{$safe ? :on : :off}!"
      end
    end
  end
end