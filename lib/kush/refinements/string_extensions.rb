module Kush
  module Refinements
    module StringExtensions
      refine String do
        def pad(n=1, chr=' ')
          chr * n + self + chr * n
        end

        def lpad(n=1, chr=' ')
          chr * n + self
        end

        def rpad(n=1, chr=' ')
          self + chr * n
        end
      end
    end
  end
end
