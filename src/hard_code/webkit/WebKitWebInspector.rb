module WebKit
  class WebKit::WebInspector < WebKit::GLibProvider
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_inspector_get_type(self)
    end


    # returns:  -> pointer
    def get_web_view()
      r = Lib.webkit_web_inspector_get_web_view(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> string
    def get_inspected_uri()
      r = Lib.webkit_web_inspector_get_inspected_uri(self)
    end


    # x_ -> 
    # y_ -> 
    # returns:  -> void
    def inspect_coordinates(x_,y_)
      begin; x_ = RGI.rval2gobj(x_); rescue; end
      begin; y_ = RGI.rval2gobj(y_); rescue; end
      r = Lib.webkit_web_inspector_inspect_coordinates(self,x_,y_)
    end


    # returns:  -> void
    def show()
      r = Lib.webkit_web_inspector_show(self)
    end


    # returns:  -> void
    def close()
      r = Lib.webkit_web_inspector_close(self)
    end
    def initialize(*o)
      if o[0].is_a? Hash
	    if ptr=o[0][:ptr]
	      @ptr = ptr
   	    else
	      fail('Invalid construct')
	    end
      else
	    @ptr = self.class.real_new(*o)
      end
      super @ptr
    end
    
    def to_ptr
      @ptr
    end
    
    def self.real_new()
      Lib.webkit_web_inspector_new()
    end

  end
end
