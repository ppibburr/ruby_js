module WebKit
  class WebKit::SecurityOrigin < WebKit::GLibProvider
    # returns:  -> int
    def get_type()
      r = Lib.webkit_security_origin_get_type(self)
    end


    # returns:  -> string
    def get_protocol()
      r = Lib.webkit_security_origin_get_protocol(self)
    end


    # returns:  -> string
    def get_host()
      r = Lib.webkit_security_origin_get_host(self)
    end


    # returns:  -> int
    def get_port()
      r = Lib.webkit_security_origin_get_port(self)
    end


    # returns:  -> int
    def get_web_database_usage()
      r = Lib.webkit_security_origin_get_web_database_usage(self)
    end


    # returns:  -> int
    def get_web_database_quota()
      r = Lib.webkit_security_origin_get_web_database_quota(self)
    end


    # quota_ -> 
    # returns:  -> void
    def set_web_database_quota(quota_)
      r = Lib.webkit_security_origin_set_web_database_quota(self,quota_)
    end


    # returns:  -> pointer
    def get_all_web_databases()
      r = Lib.webkit_security_origin_get_all_web_databases(self)
      begin
        RGI.gobj2rval(r)
      rescue
        r
      end
    end


  end
end
