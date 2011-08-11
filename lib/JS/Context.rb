module JS
  module Context

    def get_global_object()
      res = JS::Lib.JSContextGetGlobalObject(self)
      context = self
      return check_use(res) || is_self(res) || JS::Object.from_pointer_with_context(context,res)
    end

    def get_group()
      res = JS::Lib.JSContextGetGroup(self)
    end
  end
end
