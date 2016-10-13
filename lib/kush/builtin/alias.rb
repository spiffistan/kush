module Kush
  module Builtin
    module Alias

      extend  BuiltinUtils
      extend  Utils
      include Keycodes

      def self.execute!(*args)
        args = merge_args(*args)
        botch! 'Invalid arguments' unless valid?(args)
        key, value = args.split('=').map(&:strip)
        botch! "Key not valid: #{key}" unless key =~ (/^[a-zA-Z]$/)
        aliases[key.to_sym] = Command.clean(value)
      end

      def self.exist?(name)
        aliases.has_key?(name.to_sym)
      end

      def self.[](name)
        aliases[name.to_sym]
      end

      def self.list
        aliases.empty? ? 'No aliases' : aliases.map { |k,v| "#{k} #{GLYPH_RSAQUO.color(:cyan)} #{v}" }
      end

      def self.valid?(args)
        args && !args.empty? && args.include?('=')
      end

      private

      def self.aliases
        @@aliases ||= {}
      end
    end
  end
end
