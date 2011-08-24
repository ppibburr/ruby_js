module WebKit
  class WebKit::WebHistoryItem # would be subclass of GObject::Object
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_history_item_get_type(self)
    end


    # returns:  -> string
    def get_title()
      r = Lib.webkit_web_history_item_get_title(self)
    end


    # returns:  -> string
    def get_alternate_title()
      r = Lib.webkit_web_history_item_get_alternate_title(self)
    end


    # title_ -> 
    # returns:  -> void
    def set_alternate_title(title_)
      r = Lib.webkit_web_history_item_set_alternate_title(self,title_)
    end


    # returns:  -> string
    def get_uri()
      r = Lib.webkit_web_history_item_get_uri(self)
    end


    # returns:  -> string
    def get_original_uri()
      r = Lib.webkit_web_history_item_get_original_uri(self)
    end


    # returns:  -> pointer
    def get_last_visited_time()
      r = Lib.webkit_web_history_item_get_last_visited_time(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def copy()
      r = Lib.webkit_web_history_item_copy(self)
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
    end
    
    def to_ptr
      @ptr
    end
    
    def self.real_new()
      Lib.webkit_web_history_item_new()
    end



    # uri_ -> 
    # title_ -> 
    # returns:  -> pointer
    # there is this in Lib -> Lib.webkit_web_history_item_new_with_data(urititle)


  end
end
