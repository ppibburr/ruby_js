module WebKit
  class WebKit::WebFrame # would be subclass of GObject::Object
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_frame_get_type(self)
    end


    # returns:  -> pointer
    def get_web_view()
      r = Lib.webkit_web_frame_get_web_view(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> string
    def get_name()
      r = Lib.webkit_web_frame_get_name(self)
    end


    # returns:  -> string
    def get_title()
      r = Lib.webkit_web_frame_get_title(self)
    end


    # returns:  -> string
    def get_uri()
      r = Lib.webkit_web_frame_get_uri(self)
    end


    # returns:  -> pointer
    def get_parent()
      r = Lib.webkit_web_frame_get_parent(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # uri_ -> 
    # returns:  -> void
    def load_uri(uri_)
      r = Lib.webkit_web_frame_load_uri(self,uri_)
    end


    # content_ -> 
    # mime_type_ -> 
    # encoding_ -> 
    # base_uri_ -> 
    # returns:  -> void
    def load_string(content_,mime_type_,encoding_,base_uri_)
      r = Lib.webkit_web_frame_load_string(self,content_,mime_type_,encoding_,base_uri_)
    end


    # content_ -> 
    # base_url_ -> 
    # unreachable_url_ -> 
    # returns:  -> void
    def load_alternate_string(content_,base_url_,unreachable_url_)
      r = Lib.webkit_web_frame_load_alternate_string(self,content_,base_url_,unreachable_url_)
    end


    # request_ -> 
    # returns:  -> void
    def load_request(request_)
      begin; request_ = RGI.rval2gobj(request_); rescue; end
      r = Lib.webkit_web_frame_load_request(self,request_)
    end


    # returns:  -> void
    def stop_loading()
      r = Lib.webkit_web_frame_stop_loading(self)
    end


    # returns:  -> void
    def reload()
      r = Lib.webkit_web_frame_reload(self)
    end


    # name_ -> 
    # returns:  -> pointer
    def find_frame(name_)
      r = Lib.webkit_web_frame_find_frame(self,name_)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_global_context()
      r = Lib.webkit_web_frame_get_global_context(self)
     
        JS::GlobalContext.new(:pointer=>r)

    end


    # operation_ -> 
    # action_ -> 
    # error_ -> 
    # returns:  -> int
    def print_full(operation_,action_,error_)
      begin; error_ = RGI.rval2gobj(error_); rescue; end
      r = Lib.webkit_web_frame_print_full(self,operation_,action_,error_)
    end


    # returns:  -> void
    def print()
      r = Lib.webkit_web_frame_print(self)
    end


    # returns:  -> pointer
    def get_load_status()
      r = Lib.webkit_web_frame_get_load_status(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> int
    def get_horizontal_scrollbar_policy()
      r = Lib.webkit_web_frame_get_horizontal_scrollbar_policy(self)
    end


    # returns:  -> int
    def get_vertical_scrollbar_policy()
      r = Lib.webkit_web_frame_get_vertical_scrollbar_policy(self)
    end


    # returns:  -> pointer
    def get_data_source()
      r = Lib.webkit_web_frame_get_data_source(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_provisional_data_source()
      r = Lib.webkit_web_frame_get_provisional_data_source(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_security_origin()
      r = Lib.webkit_web_frame_get_security_origin(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_network_response()
      r = Lib.webkit_web_frame_get_network_response(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # web_view_ -> 
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
    
    def self.real_new(web_view_)
      Lib.webkit_web_frame_new(web_view_)
    end



  end
end
