require 'set'

require_relative 'builtin/chdir'
require_relative 'builtin/exit'
require_relative 'builtin/exec'
require_relative 'builtin/safe'
require_relative 'builtin/setenv'
require_relative 'builtin/alias'

require_relative 'builtin/jumper'
require_relative 'builtin/history'
require_relative 'builtin/completion'

module Kush
  module Builtin
    extend self

    include Kush::Keycodes

    PROTECTED = %i(quit).freeze

    BUILTINS = {
      cd:   Chdir.method(:execute!).to_proc,
      exit: Exit.method(:execute!).to_proc,
      exec: Exec.method(:execute!).to_proc,
      safe: Safe.method(:execute!).to_proc,
      set:  Setenv.method(:execute!).to_proc,
      hist: ->(n = 100) { Shell.info History.last(n) },
      al:   Alias.method(:execute!).to_proc,
      als: proc { Shell.info Alias.list },
      quit: -> { Shell.quit! },
      j:    Jumper.method(:execute!).to_proc,
      jumps: -> { Jumper.list },
      enable: ->(builtin) { enable! builtin },
      disable: ->(builtin) { disable! builtin },
      enabled: -> { list_enabled },
      disabled: -> { list_disabled },
      builtins: -> { list_all }
    }.freeze

    def self.load!
      @@disabled = Set.new
      History.load! Shell::CONFIG[:history]
      Jumper.load! Shell::CONFIG[:jumper]
    end

    def self.execute!(builtin, args)
      return unless enabled?(builtin)
      BUILTINS[builtin.to_sym].call(*args)
    end

    def self.exist?(builtin)
      BUILTINS.has_key?(builtin.to_sym)
    end

    def self.disabled?(builtin)
      @@disabled.include?(builtin.to_sym)
    end

    def self.enabled?(builtin)
      !disabled?(builtin.to_sym)
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
      BUILTINS.keys - @@disabled.to_a
    end

    def self.list_all
      Shell.info BUILTINS.keys.map { |builtin|
        enabled?(builtin) ? builtin : builtin.to_s.color(:red).underline
      }.join(ITEM_SEP.color(:cyan))
    end

    def self.list_enabled
      Shell.info enabled.to_a.join(ITEM_SEP.color(:cyan))
    end

    def self.list_disabled
      Shell.info disabled.to_a.join(ITEM_SEP.color(:cyan))
    end

    def self.merge_args(args)
      return nil if args.empty?
      Array(args).join(' ')
    end
  end
end
