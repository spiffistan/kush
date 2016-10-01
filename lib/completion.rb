module Kush
  module Completion
    def self.complete_all(text)
      completions = []
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
