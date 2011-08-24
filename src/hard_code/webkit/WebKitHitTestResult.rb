module WebKit
  class WebKit::HitTestResult # would be subclass of GObject::Object
    # returns:  -> int
    def get_type()
      r = Lib.webkit_hit_test_result_get_type(self)
    end


  end
end
