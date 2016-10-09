require_relative 'keycodes'

module Kush
  class Line

    include Kush::Keycodes

    attr_reader :commands

    def initialize(string)
      parse string
    end

    def execute!
      @commands.map(&:spawn!)
    end

    private

    def parse(string)
      @commands = [Command.new(string, env: ENV)]
      # string.split(GLYPH_DOT).each do |command|
      #   @commands << Command.new(command)
      # end
    end
  end
end
