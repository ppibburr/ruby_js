module WebKit
  class WebKit::HitTestResult < WebKit::GLibProvider
    # returns:  -> int
    def get_type()
      r = Lib.webkit_hit_test_result_get_type(self)
    end


  end
end
