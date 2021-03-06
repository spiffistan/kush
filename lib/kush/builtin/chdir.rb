module Kush
  module Builtin
    module Chdir
      extend self

      def self.execute!(directory = ENV['HOME'])
        Jumper.add(directory) if Builtin.active?(:jumper)
        Dir.chdir(directory)
        print Shell.title!
      end
    end
  end
end
