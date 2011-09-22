

module Rwt
  module UI
    module Scrollable
      def self.extended(q)
        q.style.overflow='auto'
      end
    end
  end
end
