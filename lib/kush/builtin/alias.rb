module Kush
  module Builtin
    module Alias
      extend self

      include Kush::Keycodes

      def self.execute!(args)
        return unless valid?(args)
        key, value = args.split('=').map(&:strip)
        return if !key =~ (/^[a-zA-Z]$/) and Shell.info("Key not valid: #{key}")
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
