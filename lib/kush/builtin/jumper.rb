module Kush
  module Builtin
    module Jumper
      extend self

      extend Utils

      IGNORED = %w(/)

      def self.execute!(*args)
        args = merge_args(args)
        destination = args ? (search(args) || Dir.pwd) : top
        Shell.verbose "Jumping to #{destination}"
        Dir.chdir(destination)
      end

      # Adds a directory to the jump database
      def self.add(path)
        absolute_path = File.absolute_path(path)
        return unless File.stat(absolute_path).directory? && !ignore?(absolute_path)
        Shell.verbose "Added #{absolute_path} to jump db (popularity was #{jumps[absolute_path] || 0})"
        jumps[absolute_path] = (jumps[absolute_path] || 1) + 1
      end

      # Outputs the jump database
      def self.list
        Shell.info(jumps.sort_by { |_,v| v.to_i }.reverse.map { |dir| format("%4d: %s", dir[1].to_i, dir[0]) } )
      end

      # Finds the most popular directory
      def self.top(list=jumps)
        list.max_by { |_,v| v }&.first
      end

      def self.search(string)
        basename_matches = jumps.select { |k,_| k.split('/').last.downcase.include?(string.downcase) }
        return top(basename_matches) unless basename_matches.empty?
        substring_matches = jumps.select { |k,_| k.downcase.include?(string.downcase) }
        return top(substring_matches)
      end

      def self.ignore?(directory)
        directory.nil? || IGNORED.include?(directory)
      end

      def self.jumps
        @@jumps ||= {}
      end

      def self.save!(file)
        Dir.chdir(ENV['HOME']) do
          content = jumps.map { |k,v| "#{k}: #{v}" }.join("\n")
          File.open(file, 'w') { |f| f.write(content + "\n") }
        end
      end

      def load!(file)
        Dir.chdir(ENV['HOME']) do
          return unless File.exist?(file)
          File.readlines(file)
          .reject { |line| line.chomp.empty? }
          .each do |line|
            directory, popularity = line.split(':')
            jumps[directory.strip] = popularity.chomp.strip.to_i
          end
        end
      end
    end
  end
end
