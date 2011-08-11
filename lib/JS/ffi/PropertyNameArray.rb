module JS
  module Lib
    class PropertyNameArray < JS::BaseObject

      # @param array => :JSPropertyNameArrayRef
      # retuen => JSPropertyNameArrayRef
      def retain(array)
        JS::Lib.JSPropertyNameArrayRetain(array)
      end

      # @param array => :JSPropertyNameArrayRef
      # retuen => void
      def release(array)
        JS::Lib.JSPropertyNameArrayRelease(array)
      end

      # @param array => :JSPropertyNameArrayRef
      # retuen => size_t
      def get_count(array)
        JS::Lib.JSPropertyNameArrayGetCount(array)
      end

      # @param array => :JSPropertyNameArrayRef
      # @param index => :size_t
      # retuen => JSStringRef
      def get_name_at_index(array,index)
        JS::Lib.JSPropertyNameArrayGetNameAtIndex(array,index)
      end
    end
  end
end
