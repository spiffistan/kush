module Kush
  module Builtin
    module Source

      extend self
      extend Utils
      extend BuiltinUtils

      def self.execute!(*args)
        args.each { |file| load! file }
      end

      private

      def self.load!(file)
        verbose "Sourcing #{file}..."
        Dir.chdir(ENV['HOME']) do
          botch! "Cannot source #{file}: no such file" unless File.exist?(file)
          File.readlines(file).map do |line|
            Line.new(line, system: true).execute!
          end
        end
      end
    end
  end
end
