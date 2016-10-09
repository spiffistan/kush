module Kush
  module Builtin
    module Completion
      extend self

      def self.complete_all(text)
        completions = []
        current = Dir["#{text}*"]
        return current unless current.empty?
        ENV['PATH'].split(':').each do |path|
          next unless Dir.exist? path
          Dir.chdir(path) do
            completions << Dir["#{text}*"]
          end
        end
        completions.flatten
      end
    end
  end
end
