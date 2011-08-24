module WebKit
  class WebKit::WebDatabase # would be subclass of GObject::Object
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_database_get_type(self)
    end


    # returns:  -> pointer
    def get_security_origin()
      r = Lib.webkit_web_database_get_security_origin(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


    # returns:  -> string
    def get_name()
      r = Lib.webkit_web_database_get_name(self)
    end


    # returns:  -> string
    def get_display_name()
      r = Lib.webkit_web_database_get_display_name(self)
    end


    # returns:  -> int
    def get_expected_size()
      r = Lib.webkit_web_database_get_expected_size(self)
    end


    # returns:  -> int
    def get_size()
      r = Lib.webkit_web_database_get_size(self)
    end


    # returns:  -> string
    def get_filename()
      r = Lib.webkit_web_database_get_filename(self)
    end


    # returns:  -> void
    def remove()
      r = Lib.webkit_web_database_remove(self)
    end


    # returns:  -> void
    def webkit_remove_all_web_databases()
      r = Lib.webkit_remove_all_web_databases(self)
    end


    # returns:  -> string
    def webkit_get_web_database_directory_path()
      r = Lib.webkit_get_web_database_directory_path(self)
    end


    # path_ -> 
    # returns:  -> void
    def webkit_set_web_database_directory_path(path_)
      r = Lib.webkit_set_web_database_directory_path(self,path_)
    end


    # returns:  -> int
    def webkit_get_default_web_database_quota()
      r = Lib.webkit_get_default_web_database_quota(self)
    end


    # defaultQuota_ -> 
    # returns:  -> void
    def webkit_set_default_web_database_quota(defaultQuota_)
      r = Lib.webkit_set_default_web_database_quota(self,defaultQuota_)
    end


  end
end
