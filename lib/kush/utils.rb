require_relative 'keycodes'

module Kush
  module Utils

    include Keycodes

    def cwd_git_dir?
      File.basename(%x(git rev-parse --git-dir 2>/dev/null).chomp) == '.git'
    end

    def merge_args(*args)
      return nil if args.empty?
      Array(args).join(' ')
    end

    def deep_debug(what)
      info(what, STDERR, :red) if $deep_debug
    end

    def debug(what)
      info(what, STDERR, :yellow) if $debug
    end

    def info(text, io=STDOUT, color=:cyan)
      return if text.empty?
      io.puts Array(text).map { |t| format("%s %s", "#{GLYPH_RANGLE * 2}".color(color), t.to_s.chomp) }
    end
  end
end


module Kush
  module BuiltinUtils
    def botch!(message)
      STDERR.puts message.color(:red) and return
    end
  end
end
