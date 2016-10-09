module Kush
  module Builtin
    module Source
      extend self

      def self.execute!(args)
        Array(args).each { |file| load! file }
      end

      def self.load!(file)
        Dir.chdir(ENV['HOME']) do
          return unless File.exist?(file)
          # File.readlines(file).map { |line| Builtin.shell.evaluate line }
        end
      end
    end
  end
end
