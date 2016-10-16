require_relative 'refinements/string_extensions'

module Kush
  module Prompt

    using   Refinements::StringExtensions
    extend  Utils

    PS1 = '$DIR '.color(:white).bright + '$GIT_BRANCH'.color(:magenta).italic + '$LAMBDA'.color(:cyan) + ' '

    PROMPT_VARS = {
      CWD: -> { Dir.pwd },
      DIR: -> { File.basename(Dir.getwd) },
      LAMBDA: -> { λ = 'λ'; λ = λ.underline if $safe; λ },
      GIT_BRANCH: -> { return unless cwd_git_dir?; %x(git symbolic-ref --short HEAD).chomp.rpad }
    }

    def self.formatted!
      prompt = PS1.dup
      PROMPT_VARS.each do |k, v|
        prompt.gsub! "$#{k}", v.respond_to?(:call) ? v.call : v
      end
      prompt
    end
  end
end
