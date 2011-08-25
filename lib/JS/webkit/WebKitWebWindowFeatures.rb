module WebKit
  class WebKit::WebWindowFeatures < WebKit::GLibProvider
    # returns:  -> int
    def get_type()
      r = Lib.webkit_web_window_features_get_type(self)
    end


    # features1_ -> 
    # features2_ -> 
    # returns:  -> bool
    def equal(features1_,features2_)
      begin; features1_ = RGI.rval2gobj(features1_); rescue; end
      begin; features2_ = RGI.rval2gobj(features2_); rescue; end
      r = Lib.webkit_web_window_features_equal(self,features1_,features2_)
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
      super @ptr
    end
    
    def to_ptr
      @ptr
    end
    
    def self.real_new()
      Lib.webkit_web_window_features_new()
    end



  end
end
