module JS
  module Lib
    class Context < JS::BaseObject

      # @param ctx => :JSContextRef
      # retuen => JSObjectRef
      def get_global_object(ctx)
        JS::Lib.JSContextGetGlobalObject(ctx)
      end

      # @param ctx => :JSContextRef
      # retuen => JSContextGroupRef
      def get_group(ctx)
        JS::Lib.JSContextGetGroup(ctx)
      end
    end
  end
end
