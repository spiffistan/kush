require_relative 'glyphs'

module Kush
  module Utils

    include Glyphs

    def cwd_git_dir?
      File.basename(%x(git rev-parse --git-dir 2>/dev/null).chomp) == '.git'
    end

    def merge_args(*args)
      return nil if args.empty?
      Array(args).join(' ')
    end

    def deep_debug(text)
      info(text, STDERR, :red) if $deep_debug
    end

    def debug(text)
      info(text, STDERR, :yellow) if $debug
    end

    def verbose(text)
      info(text, STDERR, :white) if $verbose
    end

    def info(text, io=STDOUT, color=:cyan)
      return if text.empty?
      io.puts Array(text).map { |t| format("%s %s", "#{GLYPH_RANGLE * 2}".color(color), t.to_s.chomp) }
    end
  end
end
