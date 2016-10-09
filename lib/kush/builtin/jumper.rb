module Kush
  module Builtin
    module Jumper
      extend self

      IGNORED = %w(/)

      # Finds the most popular directory
      def self.find(search)
        @@jumpdb.select { |k,_| k =~ /#{search}+/ }.sort_by { |_,v| v }&.first&.first || Dir.pwd
      end

      # Adds a directory to the jump database
      def self.add(path)
        absolute_path = File.absolute_path(path) rescue nil
        return if ignore?(absolute_path) || !File.stat(absolute_path).directory?
        Shell.info "Added #{absolute_path} to jump db"
        @@jumpdb[path] = (@@jumpdb[path] || 1) + 1
      end

      def self.list
        Shell.info @@jumpdb.sort_by { |_,v| v }
      end

      def self.ignore?(directory)
        directory.nil? || IGNORED.include?(directory)
      end

      def self.save!(file)
        Dir.chdir(ENV['HOME']) do
          content = @@jumpdb.map { |k,v| "#{k}: #{v}" }.join("\n")
          File.open(file, 'w') { |f| f.write(content + "\n") }
        end
      end

      def load!(file)
        @@jumpdb = {}
        Dir.chdir(ENV['HOME']) do
          if File.exist?(file)
            File.readlines(file)
            .reject { |line| line.empty? || line == "\n" }
            .each do |line|
              directory, popularity = line.split(':')
              @@jumpdb[directory.strip] = popularity.to_i
            end
          end
        end
      end
    end
  end
end
