

module Rwt
  module UI
    module Scrollable
      def self.extended(q)
        q.style.overflow='scroll'
      end
    end
  end
end
