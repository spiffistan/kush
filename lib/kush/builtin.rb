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
      'quit'     => -> { Shell.quit! },
      'builtin'  => Builtin,
      'cd'       => Chdir,
      'exit'     => Exit,
      'exec'     => Exec,
      'safe'     => Safe,
      'set'      => Setenv,
      'src'      => Source,
      'aka'      => Alias,
      'jump'     => Jumper,
      'hist'     => History,
      'path'     => -> { Shell.info ENV['PATH'].split(':') }
    }.freeze

    def self.load_all!(config)
      @@disabled = Set.new
      Source.load!  config[:rc]
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

    # Handles execution of other builtins
    def self.builtin!(*args)
      name, *args = *args
      botch! "Builtin #{name} does not exist" unless exist?(name)
      builtin = BUILTINS[name]
      builtin.is_a?(Module) ? builtin.send(:execute!, *args) : builtin.call
    end

    def self.active?(builtin)
      exist?(builtin) && enabled?(builtin)
    end

    def self.disabled?(builtin)
      disabled.include?(builtin.to_s)
    end

    def self.enabled?(builtin)
      !disabled?(builtin.to_s)
    end

    def self.disabled
      @@disabled ||= Set.new
    end

    def self.enabled
      BUILTINS.keys - disabled.to_a
    end

    def self.list_all
      Shell.info BUILTINS.keys.map do |builtin|
        b = builtin.color(:red).underline if disabled?(builtin)
        b = builtin.color(:cyan).underline if protected?(builtin)
        b ? b : builtin
      end.join(ITEM_SEP.color(:cyan))
    end

    private # __________________________________________________________________

    def self.exist?(builtin)
      BUILTINS.has_key?(builtin.to_s)
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
      botch! "#{builtin} is not a builtin" unless exist?(builtin)
      botch! "#{builtin} is already disabled" if disabled?(builtin)
      disabled.delete builtin
    end
  end
end
