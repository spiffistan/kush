require_relative 'keycodes'

module Kush
  module Shell
    class Line

      include Kush::Keycodes

      attr_reader :commands

      def initialize(string)
        @commands = parse string
      end

      def parse(string)
        string.split(GLYPH_DOT).each do |part|
          @commands << Command.new(part)
        end
      end
    end

    class Command < Line

      attr_reader :kind, :command, :args

      def initialize(string, in=$stdin, out=$stdout)
        @command, *@args = *string.split(' ')
      end

      private

      def kind(command)
        Kush::Completion.executable_exists?(command)
      end

      def builtin?(word)
        Kush::Shell::BUILTINS.has_key?(word.to_sym)
      end
    end
  end
end
