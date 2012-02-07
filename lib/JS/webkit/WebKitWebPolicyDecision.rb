module WebKit
  class WebKit::WebPolicyDecision < WebKit::GLibProvider
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_policy_decision_get_type(self)
    end


    # returns:  -> void
    def use()
      r = Lib.webkit_web_policy_decision_use(self)
    end


    # returns:  -> void
    def ignore()
      r = Lib.webkit_web_policy_decision_ignore(self)
    end


    # returns:  -> void
    def download()
      r = Lib.webkit_web_policy_decision_download(self)
    end


  end
end
