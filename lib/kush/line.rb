require_relative 'keycodes'

module Kush
  class Line

    include Kush::Keycodes

    attr_reader :commands
    attr_reader :raw

    def initialize(string, opts = {})
      @opts = opts
      @raw = string
      parse @raw
    end

    def execute!
      @commands.map(&:spawn!)
      Builtin::History.add(@raw) if Builtin.enabled?(:history) && !@opts[:system]
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
