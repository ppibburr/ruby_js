module WebKit
  class WebKit::WebDataSource < WebKit::GLibProvider
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_data_source_get_type(self)
    end


    # returns:  -> pointer
    def get_web_frame()
      r = Lib.webkit_web_data_source_get_web_frame(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_initial_request()
      r = Lib.webkit_web_data_source_get_initial_request(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_request()
      r = Lib.webkit_web_data_source_get_request(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> string
    def get_encoding()
      r = Lib.webkit_web_data_source_get_encoding(self)
    end


    # returns:  -> bool
    def is_loading()
      r = Lib.webkit_web_data_source_is_loading(self)
    end


    # returns:  -> pointer
    def get_data()
      r = Lib.webkit_web_data_source_get_data(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_main_resource()
      r = Lib.webkit_web_data_source_get_main_resource(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> string
    def get_unreachable_uri()
      r = Lib.webkit_web_data_source_get_unreachable_uri(self)
    end


    # returns:  -> pointer
    def get_subresources()
      r = Lib.webkit_web_data_source_get_subresources(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
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
      super @ptr
    end
    
    def to_ptr
      @ptr
    end
    
    def self.real_new()
      Lib.webkit_web_data_source_new()
    end



    # request_ -> 
    # returns:  -> pointer
    # there is this in Lib -> Lib.webkit_web_data_source_new_with_request(request)


  end
end
