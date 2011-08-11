module JS
  module Lib
    class ContextGroup < JS::BaseObject

      def self.create()
        JS::Lib.JSContextGroupCreate()
      end

      # @param group => :JSContextGroupRef
      def retain(group)
        JS::Lib.JSContextGroupRetain(group)
      end
    end
  end
end
