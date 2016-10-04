module Kush
  class History
    attr_accessor :list, :position

    def initialize
      @history_file = Shell::CONFIG[:history]
      @list = []
      read!
      @position = list.size
    end

    def self.[](count)
      @list.last(count)
    end

    def reset_position
      @position = @list.size
    end

    def navigate(direction)
      return if list.empty?
      case direction
      when :up
        unless @position - 1 < 0
          @position -= 1
          list[@position]
        end
      when :down
        unless @position + 1 > list.size
          @position += 1
          list[@position]
        end
      end
    end

    def <<(line)
      list << line unless list.last.strip == line.strip
      append! line
    end

    private

    def read!
      Dir.chdir(ENV['HOME']) do
        @list = File.readlines(@history_file) if File.exist?(@history_file)
      end
    end

    def append!(line)
      Dir.chdir(ENV['HOME']) do
        File.open(@history_file, 'a') { |f| f.write(line + "\n") }
      end
    end
  end
end
