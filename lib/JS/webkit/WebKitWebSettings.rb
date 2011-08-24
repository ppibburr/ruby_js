module WebKit
  class WebKit::WebSettings # would be subclass of GObject::Object
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_settings_get_type(self)
    end


    # returns:  -> pointer
    def copy()
      r = Lib.webkit_web_settings_copy(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> string
    def get_user_agent()
      r = Lib.webkit_web_settings_get_user_agent(self)
    end


    # returns:  -> pointer
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
    end
    
    def to_ptr
      @ptr
    end
    
    def self.real_new()
      Lib.webkit_web_settings_new()
    end



  end
end
