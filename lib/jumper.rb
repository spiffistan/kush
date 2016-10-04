  class Jumper

    def initialize
      @@jumpdb = {}
      read! Shell::CONFIG[:jumper]
    end

    # Finds the most popular directory
    def self.find(search)
      @@jumpdb.detect { |k,v| k.split('/').last =~ /#{search}+/ }.sort_by { |_,v| v }.first || Dir.pwd
    end

    # Adds a directory to the jump database
    def self.add(directory)
      return if ignore?(directory)
      @@jumpdb[directory] = (@@jumpdb[directory] || 1) + 1
    end

    def self.list
      Shell.info @@jumpdb.sort_by { |_,v| v }
    end

    private

    def self.ignore?(directory)
      !directory.start_with?('/') || %w(. ..).include?(directory)
    end

    def self.save!(file)
      Dir.chdir(ENV['HOME']) do
        content = @@jumpdb.map { |k,v| "#{k}: #{v}" }.join("\n")
        File.open(file, 'w') { |f| f.write(content + "\n") }
      end
    end

    def read!(file)
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
