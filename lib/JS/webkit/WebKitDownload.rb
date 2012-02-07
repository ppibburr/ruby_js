module WebKit
  class WebKit::Download < WebKit::GLibProvider
    # returns:  -> int
    def get_type()
      r = Lib.webkit_download_get_type(self)
    end


    # returns:  -> void
    def start()
      r = Lib.webkit_download_start(self)
    end


    # returns:  -> void
    def cancel()
      r = Lib.webkit_download_cancel(self)
    end


    # returns:  -> string
    def get_uri()
      r = Lib.webkit_download_get_uri(self)
    end


    # returns:  -> pointer
    def get_network_request()
      r = Lib.webkit_download_get_network_request(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_network_response()
      r = Lib.webkit_download_get_network_response(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> string
    def get_suggested_filename()
      r = Lib.webkit_download_get_suggested_filename(self)
    end


    # returns:  -> string
    def get_destination_uri()
      r = Lib.webkit_download_get_destination_uri(self)
    end


    # destination_uri_ -> 
    # returns:  -> void
    def set_destination_uri(destination_uri_)
      r = Lib.webkit_download_set_destination_uri(self,destination_uri_)
    end


    # returns:  -> pointer
    def get_progress()
      r = Lib.webkit_download_get_progress(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_elapsed_time()
      r = Lib.webkit_download_get_elapsed_time(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> int
    def get_total_size()
      r = Lib.webkit_download_get_total_size(self)
    end


    # returns:  -> int
    def get_current_size()
      r = Lib.webkit_download_get_current_size(self)
    end


    # returns:  -> pointer
    def get_status()
      r = Lib.webkit_download_get_status(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # request_ -> 
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
    
    def self.real_new(request_)
      Lib.webkit_download_new(request_)
    end



  end
end
