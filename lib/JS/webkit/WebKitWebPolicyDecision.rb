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
    
    def self.real_new()
      Lib.webkit_web_policy_decision_new()
    end

  end
end
