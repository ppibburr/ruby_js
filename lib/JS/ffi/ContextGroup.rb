module JS
  module Lib
    class ContextGroup < JS::BaseObject

      # retuen => JSContextGroupRef
      def self.create()
        JS::Lib.JSContextGroupCreate()
      end

      # @param group => :JSContextGroupRef
      # retuen => JSContextGroupRef
      def retain(group)
        JS::Lib.JSContextGroupRetain(group)
      end
    end
  end
end
