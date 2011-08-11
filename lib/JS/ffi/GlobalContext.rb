module JS
  module Lib
    class GlobalContext < JS::BaseObject

      # @param globalObjectClass => :JSClassRef
      def self.create(globalObjectClass)
        JS::Lib.JSGlobalContextCreate(globalObjectClass)
      end

      # @param group => :JSContextGroupRef
      # @param globalObjectClass => :JSClassRef
      def self.create_in_group(group,globalObjectClass)
        JS::Lib.JSGlobalContextCreateInGroup(group,globalObjectClass)
      end

      # @param ctx => :JSGlobalContextRef
      def retain(ctx)
        JS::Lib.JSGlobalContextRetain(ctx)
      end

      # @param ctx => :JSGlobalContextRef
      def release(ctx)
        JS::Lib.JSGlobalContextRelease(ctx)
      end
    end
  end
end
