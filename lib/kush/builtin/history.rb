require 'date'

module Kush
  module Builtin
    module History

      extend self

      class Item
        attr_reader :timestamp, :command

        def initialize(timestamp, command)
          @timestamp = timestamp
          @command = command
        end

        def to_s
          "#{@timestamp} #{@command}"
        end
      end

      def self.execute!(*args)
        last(Config.history_lines).each do |item|
          Shell.info("%s: %s" % [item.timestamp, item.command])
        end
      end

      def self.load!(file)
        Dir.chdir(ENV['HOME']) do
          return unless File.exist?(file)
          File.readlines(file).reject { |line| line.strip.empty? }.each_with_index do |line, n|
            timestamp, command = line.split(' ')
            Shell.warning("History not loaded. Malformed history at #{file} line #{n}") and return unless timestamp && command
            list << Item.new(DateTime.parse(timestamp), command)
          end
        end
        reset_position
      end

      def self.save!(file)
        Dir.chdir(ENV['HOME']) do
          content = list.compact.sort_by(&:timestamp).join("\n")
          File.open(file, 'w') { |f| f.write(content) }
        end
      end

      def self.navigate(direction)
        return if list.empty?
        case direction
        when :up
          unless position - 1 < 0
            @@position -= 1
            list[position].command
          end
        when :down
          unless position + 1 > list.size
            @@position += 1
            list[position].command
          end
        end
      end

      def self.add(line)
        @@list << Item.new(DateTime.now, line.strip) unless list.last && list.last.command.strip == line.strip
      end

      def self.reset_position
        @@position = list.size
      end

      private

      def self.list
        @@list ||= []
      end

      def self.position
        @@position ||= list.size
      end

      def self.clear
        @@list = []
      end

      def self.last(count)
        list.last(count)
      end
    end
  end
end
