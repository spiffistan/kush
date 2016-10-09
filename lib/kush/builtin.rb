require 'set'

require_relative 'builtin/chdir'
require_relative 'builtin/exit'
require_relative 'builtin/exec'
require_relative 'builtin/safe'
require_relative 'builtin/setenv'

require_relative 'builtin/jumper'
require_relative 'builtin/history'
require_relative 'builtin/completion'

module Kush
  module Builtin
    extend self

    PROTECTED = %i(quit)

    BUILTINS = {
      cd:   proc { Chdir.execute! },
      exit: proc { Exit.execute! },
      exec: proc { Exec.execute! },
      safe: proc { Safe.execute! },
      set:  proc { Setenv.execute! },
      hist: ->(n = 100) { Shell.info History.last(n) },
      quit: -> { Shell.quit! },
      j: ->(directory) { BUILTINS[:cd].call(Jumper.find(directory)) && Shell.info(Dir.pwd) },
      # jumps: -> { Jumper.list },
      enable: ->(builtin) { enable! builtin },
      disable: ->(builtin) { disable! builtin },
      enabled: -> { list_enabled },
      disabled: -> { list_disabled },
      builtins: -> { list_all }
    }

    def self.load!
      @@disabled = Set.new
      History.load! Shell::CONFIG[:history]
      Jumper.load! Shell::CONFIG[:jumper]
    end

    def self.exist?(builtin)
      BUILTINS.has_key?(builtin.to_sym)
    end

    def self.disabled?(builtin)
      @@disabled.include?(builtin)
    end

    def self.enabled?(builtin)
      !disabled?(builtin)
    end

    def self.execute!(builtin, args)
      return unless enabled?(builtin)
      BUILTINS[builtin.to_sym].call(*args)
    end

    def self.disable!(builtin)
      return unless BUILTINS.keys.include?(builtin.to_sym)
      return if PROTECTED.include?(builtin.to_sym)
      @@disabled.insert builtin.to_sym
    end

    def self.disable!(builtin)
      return unless disabled?(builtin)
      @@disabled.delete builtin.to_sym
    end

    def self.disabled
      @@disabled
    end

    def self.enabled
      BUILTINS.keys - @@disabled
    end

    def self.list_all
      Shell.info BUILTINS.keys.map do |builtin|
        enabled?(builtin) ? builtin : builtin.to_s.color(:red).underline
      end.join(', ')
    end

    def self.list_enabled
      Shell.info enabled.join(', ')
    end

    def self.list_disabled
      Shell.info disabled.join(', ')
    end
  end
end
