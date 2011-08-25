module WebKit
  class WebKit::NetworkResponse < WebKit::GLibProvider
    # returns:  -> int
    def get_type()
      r = Lib.webkit_network_response_get_type(self)
    end


    # uri_ -> 
    # returns:  -> void
    def set_uri(uri_)
      r = Lib.webkit_network_response_set_uri(self,uri_)
    end


    # returns:  -> string
    def get_uri()
      r = Lib.webkit_network_response_get_uri(self)
    end


    # returns:  -> pointer
    def get_message()
      r = Lib.webkit_network_response_get_message(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # uri_ -> 
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
      super @ptr
    end
    
    def to_ptr
      @ptr
    end
    
    def self.real_new(uri_)
      Lib.webkit_network_response_new(uri_)
    end



  end
end
