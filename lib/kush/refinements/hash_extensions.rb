module Kush
  module Refinements
    module HashExtensions
      refine Hash do
        def sort_by_value(&block)
          self.sort_by { |_,v| block ? block.call(v) : v }
        end
        def sort_by_key(&block)
          self.sort_by { |k,_| block ? block.call(k) : k }
        end
      end
    end
  end
end
