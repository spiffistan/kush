require 'set'

module Kush
  class Builtins

    BUILTINS = {
      cd:   ->(directory = ENV['HOME']) { Dir.chdir(directory) and Jumper.add(directory) },
      exit: ->(code = 0) { exit(code.to_i) },
      exec: ->(*command) { exec *command },
      safe: -> { Shell.toggle_safe! },
      set:  ->(args) { key, value = args.split('='); ENV[key] = value },
      hist: :print_history,
      quit: -> { Shell.quit! },
      j: ->(directory) { BUILTINS[:cd].call(Jumper.find(directory)) },
      jumps: -> { Jumper.list },
      enable: ->(builtin) { @@disabled.add builtin },
      disable: ->(builtin) { @@disabled.remove builtin },
      builtins: -> { Shell.info BUILTINS.keys.join(' ') }
    }

    def initialize
      @@disabled = Set.new
    end

    def self.exist?(builtin)
      BUILTINS.has_key?(builtin)
    end

    def self.execute!(builtin, args)
      return unless enabled?(builtin)
      BUILTINS[builtin.to_sym].respond_to?(:call) ? BUILTINS[builtin.to_sym].call(*args) : self.send(BUILTINS[builtin.to_sym], *args)
    end


    def self.print_history
      STDERR.puts History[10000]
    end

    private

    def self.enabled?(builtin)
      !@@disabled.include?(builtin)
    end
  end

end
