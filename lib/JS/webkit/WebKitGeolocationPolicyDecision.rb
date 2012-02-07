module WebKit
  class WebKit::GeolocationPolicyDecision < WebKit::GLibProvider
    # returns:  -> int
    def get_type()
      r = Lib.webkit_geolocation_policy_decision_get_type(self)
    end


    # returns:  -> void
    def webkit_geolocation_policy_allow()
      r = Lib.webkit_geolocation_policy_allow(self)
    end


    # returns:  -> void
    def webkit_geolocation_policy_deny()
      r = Lib.webkit_geolocation_policy_deny(self)
    end


  end
end
