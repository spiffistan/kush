module Kush
  module Builtin
    module Chdir
      extend self

      def self.execute!(directory = ENV['HOME'])
        Jumper.add(directory) if Builtin.enabled?(:jumper)
        Dir.chdir(directory)
      end
    end
  end
end
