require 'set'
require 'optparse'

require_relative 'builtin/chdir'
require_relative 'builtin/exit'
require_relative 'builtin/exec'
require_relative 'builtin/safe'
require_relative 'builtin/setenv'
require_relative 'builtin/alias'
require_relative 'builtin/source'

require_relative 'builtin/jumper'
require_relative 'builtin/history'
require_relative 'builtin/completion'

module Kush
  module Builtin
    extend self

    include Kush::Keycodes

    PROTECTED = %w(quit builtin).freeze

    BUILTINS = {
      'builtin'  => Builtin,
      'cd'       => Chdir,
      'exit'     => Exit,
      'exec'     => Exec,
      'safe'     => Safe,
      'set'      => Setenv,
      'source'   => Source,
      'al'       => Alias,
      'j'        => Jumper,
      'hist'     => History,
      'als'      => Alias,
      'path'     => -> { Shell.info ENV['PATH'].split(':') },
      'quit'     => -> { Shell.quit! }
    }.freeze

    def self.load_all!(config)
      @@disabled = Set.new
      # Source.load!  config[:rc]
      History.load! config[:history]
      Jumper.load!  config[:jumper]
    end

    # Handles the 'builtin' command
    def self.execute!(*args)
      OptionParser.new do |opt|
        opt.on('-d', '--disable=name', String) { |name| disable! name }
        opt.on('-e', '--enable=name',  String) { |name| enable!  name }
        opt.on('-l', '--list')                 { list_all }
      end.parse!(args)
    end

    def self.disabled?(builtin)
      disabled.include?(builtin)
    end

    def self.enabled?(builtin)
      !disabled?(builtin)
    end

    def self.disabled
      @@disabled ||= Set.new
    end

    def self.enabled
      BUILTINS.keys - disabled.to_a
    end

    def self.list_all
      Shell.info BUILTINS.keys.map { |builtin|
        enabled?(builtin) ? builtin : builtin.to_s.color(:red).underline
      }.join(ITEM_SEP.color(:cyan))
    end

    # Handles executions of other builtins
    def self.builtin!(*args)
      name, *args = *args
      botch! "Builtin #{name} does not exist" unless exist?(name)
      builtin = BUILTINS[name]
      builtin.is_a?(Module) ? builtin.send(:execute!, *args) : builtin
    end

    private # __________________________________________________________________

    def self.exist?(builtin)
      BUILTINS.has_key?(builtin)
    end

    def self.protected?(builtin)
      PROTECTED.include?(builtin)
    end

    def self.disable!(builtin)
      botch! "#{builtin} is not a builtin" unless exist?(builtin)
      botch! "#{builtin} cannot be disabled" if protected?(builtin)
      disabled.add builtin
    end

    def self.enable!(builtin)
      botch! "#{builtin} is already disabled" if disabled?(builtin)
      disabled.delete builtin
    end

    def self.botch!(message)
      STDERR.puts message.color(:red) and return
    end
  end
end
