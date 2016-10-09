module Kush
  module Builtin
    module History
      extend self

      def self.load!(file)
        @@list = []
        Dir.chdir(ENV['HOME']) do
          @@list = File.readlines(file).reject { |line| line.chomp.strip.empty? } if File.exist?(file)
        end
        @@position = @@list.size
      end

      def self.save!(file)
        Dir.chdir(ENV['HOME']) do
          content = @@list.compact.reject { |item| item.chomp.strip.empty? }.join("\n")
          File.open(file, 'w') { |f| f.write(content + "\n") }
        end
      end

      def self.last(count)
        @@list.last(count)
      end

      def self.reset_position
        @@position = @@list.size
      end

      def self.clear
        @@list = []
      end

      def self.navigate(direction)
        return if @@list.empty?
        case direction
        when :up
          unless @@position - 1 < 0
            @@position -= 1
            @@list[@@position]
          end
        when :down
          unless @@position + 1 > @@list.size
            @@position += 1
            @@list[@@position]
          end
        end
      end

      def self.add(line)
        @@list << line.chomp.strip unless @@list.last.chomp.strip == line.chomp.strip
      end
    end
  end
end
