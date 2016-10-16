module Kush
  module Builtin
    module Source
      extend self
      extend Utils

      def self.execute!(*args)
        args.each { |file| load! file }
      end

      private

      def self.load!(file)
        verbose "Sourcing #{file}..."
        Dir.chdir(ENV['HOME']) do
          botch! "File #{file} does not exist" unless File.exist?(file)
          File.readlines(file).map do |line|
            Line.new(line).execute!
          end
        end
      end
    end
  end
end
