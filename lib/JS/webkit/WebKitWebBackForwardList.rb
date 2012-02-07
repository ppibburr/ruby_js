module WebKit
  class WebKit::WebBackForwardList < WebKit::GLibProvider
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_back_forward_list_get_type(self)
    end


    # returns:  -> void
    def go_forward()
      r = Lib.webkit_web_back_forward_list_go_forward(self)
    end


    # returns:  -> void
    def go_back()
      r = Lib.webkit_web_back_forward_list_go_back(self)
    end


    # history_item_ -> 
    # returns:  -> bool
    def contains_item(history_item_)
      begin; history_item_ = RGI.rval2gobj(history_item_); rescue; end
      r = Lib.webkit_web_back_forward_list_contains_item(self,history_item_)
    end


    # history_item_ -> 
    # returns:  -> void
    def go_to_item(history_item_)
      begin; history_item_ = RGI.rval2gobj(history_item_); rescue; end
      r = Lib.webkit_web_back_forward_list_go_to_item(self,history_item_)
    end


    # limit_ -> 
    # returns:  -> pointer
    def get_forward_list_with_limit(limit_)
      r = Lib.webkit_web_back_forward_list_get_forward_list_with_limit(self,limit_)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # limit_ -> 
    # returns:  -> pointer
    def get_back_list_with_limit(limit_)
      r = Lib.webkit_web_back_forward_list_get_back_list_with_limit(self,limit_)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_back_item()
      r = Lib.webkit_web_back_forward_list_get_back_item(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_current_item()
      r = Lib.webkit_web_back_forward_list_get_current_item(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> pointer
    def get_forward_item()
      r = Lib.webkit_web_back_forward_list_get_forward_item(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # index_ -> 
    # returns:  -> pointer
    def get_nth_item(index_)
      r = Lib.webkit_web_back_forward_list_get_nth_item(self,index_)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> int
    def get_back_length()
      r = Lib.webkit_web_back_forward_list_get_back_length(self)
    end


    # returns:  -> int
    def get_forward_length()
      r = Lib.webkit_web_back_forward_list_get_forward_length(self)
    end


    # returns:  -> int
    def get_limit()
      r = Lib.webkit_web_back_forward_list_get_limit(self)
    end


    # limit_ -> 
    # returns:  -> void
    def set_limit(limit_)
      r = Lib.webkit_web_back_forward_list_set_limit(self,limit_)
    end


    # history_item_ -> 
    # returns:  -> void
    def add_item(history_item_)
      begin; history_item_ = RGI.rval2gobj(history_item_); rescue; end
      r = Lib.webkit_web_back_forward_list_add_item(self,history_item_)
    end


    # returns:  -> void
    def clear()
      r = Lib.webkit_web_back_forward_list_clear(self)
    end


    # web_view_ -> 
    # returns:  -> pointer
    # there is this in Lib -> Lib.webkit_web_back_forward_list_new_with_web_view(web_view)


  end
end
