module WebKit
  class WebKit::SoupAuthDialog < WebKit::GLibProvider
    # returns:  -> int
    def webkit_soup_auth_dialog_get_type()
      r = Lib.webkit_soup_auth_dialog_get_type(self)
    end


  end
end
