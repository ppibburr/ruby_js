module WebKit
  class WebKit::WebNavigationAction # would be subclass of GObject::Object
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_navigation_action_get_type(self)
    end


    # returns:  -> pointer
    def get_reason()
      r = Lib.webkit_web_navigation_action_get_reason(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # reason_ -> 
    # returns:  -> void
    def set_reason(reason_)
      begin; reason_ = RGI.rval2gobj(reason_); rescue; end
      r = Lib.webkit_web_navigation_action_set_reason(self,reason_)
    end


    # returns:  -> string
    def get_original_uri()
      r = Lib.webkit_web_navigation_action_get_original_uri(self)
    end


    # originalUri_ -> 
    # returns:  -> void
    def set_original_uri(originalUri_)
      r = Lib.webkit_web_navigation_action_set_original_uri(self,originalUri_)
    end


    # returns:  -> int
    def get_button()
      r = Lib.webkit_web_navigation_action_get_button(self)
    end


    # returns:  -> int
    def get_modifier_state()
      r = Lib.webkit_web_navigation_action_get_modifier_state(self)
    end


    # returns:  -> string
    def get_target_frame()
      r = Lib.webkit_web_navigation_action_get_target_frame(self)
    end


  end
end
