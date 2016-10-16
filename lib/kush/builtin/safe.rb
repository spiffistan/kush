module Kush
  module Builtin
    module Safe
      extend self

      def self.execute!
        Shell.toggle_safe!
        Shell.info "Safety #{$safe ? :on : :off}!"
        Shell.verbose "The shell will #{$safe ? 'not'.underline : 'now' } run executables"
      end
    end
  end
end
