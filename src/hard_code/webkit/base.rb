module WebKit
  # Class: WebKit::GLibProvider
  #
  # The base cass of all objects in the WebKit namespace
  # Holds the reference from an FFI::Pointer in a property
  # and delegates to the object returned from get_property!('real')
  # as this setups signals and such
  #
  # Instances of this class delegate the methods: get_property, signal_connect
  #   to the providee
  #
  # Subclasses of this class deleate the methods :signal, :signals, :property, :properties
  #   to providee.class
  #
  # To use the methods from above on GLibProvider instance or subclass
  #   suffix the above methods with ! ie, WebKit::WebView.properties! #=> ["real"]
  #  
  class GLibProvider < Gtk::Object
    type_register
    spec = GLib::Param::Object.new 'real','real','',GLib::Type['GObject'],3
    install_property spec,1
    
    attr_accessor :real
    # @param ptr [FFI::Pointer,Object#to_ptr] the FFI::Pointer to provide for
    def initialize ptr
      super()
      set_real ptr
      # delegate class methods
      class << self.class
        attr_accessor :__standard__
        
        alias :'signals!' :signals
        alias :'signal!' :signal
        alias :'properties!' :properties
        alias :'property!' :property
        
        def properties
          __standard__.properties
        end
        
        def property n
          __standard__.property n
        end
        
        def signal s
          __standard__.signal s
        end
        
        def signals
          __standard__.signals
        end
      end
      
      self.class.__standard__ = get_property!('real').class
      
    end
    
    def to_ptr!
      if inspect =~ /ptr\=0x([0-9a-z]+)/
        FFI::Pointer.new($1.to_i(16))
      else
        raise
      end
    end  
    
    def set_real ptr
      v= GLib::Value.new
      v.init GLib::Type['GObject']
      v.set_object ptr
      GLib::IKE.g_object_set_property to_ptr!,'real',v 
    end
    
    alias :'signal_connect!' :signal_connect
    
    # will connect signal that delegates to 
    # the return (q) for sigals, properties, gtype
    # and the suchs to the providee
    def signal_connect *o,&b
      get_property!('real').signal_connect *o,&b
    end
    
    alias :'get_property!' :get_property
    
    # will get propeties from the providee
    def get_property *o,&b
      get_property!('real').get_property *o,&b
    end  
    
    alias :'set_property!' :set_property    
    
    # will set propeties on the providee
    def set_property *o,&b
      set_property!('real').set_property *o,&b
    end 
  end
end

module RGI
  def self.gobj2rval pt
    ph = WebKit::GLibProvider.new pt 
    q=ph.get_property! 'real'
    return pt if !q
    if q.gtype.to_s =~ /WebKit(.*)/
      wk = WebKit.wrap_return_from_standard q,$1
      return wk
    end
    q
  end
end
