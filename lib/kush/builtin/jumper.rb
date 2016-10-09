module Kush
  module Builtin
    module Jumper
      extend self

      IGNORED = %w(/)

      def self.execute!(*args)
        args = Builtin.merge_args(args)
        destination = args ? (search(args) || Dir.pwd) : top
        Shell.info "Jumping to #{destination}"
        Dir.chdir(destination)
      end

      # Adds a directory to the jump database
      def self.add(path)
        absolute_path = File.absolute_path(path)
        return if ignore?(absolute_path) || !File.stat(absolute_path).directory?
        Shell.info "Added #{absolute_path} to jump db (popularity was #{@@jumpdb[absolute_path] || 0})"
        @@jumpdb[absolute_path] = (@@jumpdb[absolute_path] || 1) + 1
      end

      # Outputs the jump database
      def self.list
        Shell.info @@jumpdb
      end

      # Finds the most popular directory
      def self.top
        @@jumpdb.max_by { |_,v| v }&.first
      end

      def self.search(string)
        @@jumpdb.select { |k,_| k.downcase.include?(string.downcase) }.max_by { |_,v| v }&.first
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
            .reject { |line| line.chomp.empty? }
            .each do |line|
              directory, popularity = line.split(':')
              @@jumpdb[directory.strip] = popularity.chomp.strip.to_i
            end
          end
        end
      end
    end
  end
end
