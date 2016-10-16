require 'optparse'

module Kush
  module Builtin
    module Alias

      extend  self
      extend  BuiltinUtils
      extend  Utils
      include Glyphs

      def self.execute!(*args)
        args = merge_args(*args)
        botch! 'Invalid arguments' unless args && !args.empty? && args.include?('=')
        key, value = args.split('=').map(&:strip)
        botch! "Key not valid: #{key}" unless key =~ (/^[a-zA-Z]+$/)
        botch! "Value not valid: #{value}" unless value && !value.empty?
        aliases[key] = Command.clean(value)
      end

      def self.exist?(name)
        name && aliases.has_key?(name)
      end

      def self.[](name)
        aliases[name]
      end

      def self.list
        info 'No aliases' if aliases.empty?
        aliases.map { |k,v| "#{k} #{GLYPH_RSAQUO.color(:cyan)} #{v}" }
      end

      private # ________________________________________________________________

      def self.aliases
        @@aliases ||= {}
      end
    end
  end
end
