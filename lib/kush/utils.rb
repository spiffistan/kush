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
      info(text, STDERR, :green) if Config.deep_debug
    end

    def debug(text)
      info(text, STDERR, :blue) if Config.debug
    end

    def verbose(text)
      info(text, STDERR, :white) if Config.verbose
    end

    def warning(text)
      info('WARNING: '.bold + text, STDERR, :red) unless Config.suppress_warnings
    end

    def info(text, io=STDOUT, color=:cyan)
      return if text.empty?
      io.puts Array(text).map { |t| format("%s %s", "#{GLYPH_RANGLE * 2}".color(color), t.to_s.chomp) }
    end
  end
end
