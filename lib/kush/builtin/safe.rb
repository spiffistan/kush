module Kush
  module Builtin
    module Safe
      extend self

      def self.execute!
        Shell.toggle_safety!
        Shell.info "Safety #{Config.safety ? :on : :off}!"
        Shell.verbose "The shell will #{Config.safety ? 'not'.underline : 'now' } run executables"
      end
    end
  end
end
