module WebKit
  class WebKit::WebResource # would be subclass of GObject::Object
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_resource_get_type(self)
    end


    # returns:  -> pointer
    def get_data()
      r = Lib.webkit_web_resource_get_data(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> string
    def get_uri()
      r = Lib.webkit_web_resource_get_uri(self)
    end


    # returns:  -> string
    def get_mime_type()
      r = Lib.webkit_web_resource_get_mime_type(self)
    end


    # returns:  -> string
    def get_encoding()
      r = Lib.webkit_web_resource_get_encoding(self)
    end


    # returns:  -> string
    def get_frame_name()
      r = Lib.webkit_web_resource_get_frame_name(self)
    end


    # data_ -> 
    # size_ -> 
    # uri_ -> 
    # mime_type_ -> 
    # encoding_ -> 
    # frame_name_ -> 
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
    
    def self.real_new(data_,size_,uri_,mime_type_,encoding_,frame_name_)
      Lib.webkit_web_resource_new(data_,size_,uri_,mime_type_,encoding_,frame_name_)
    end



  end
end
