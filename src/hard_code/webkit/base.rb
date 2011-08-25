module WebKit

  # The base cass of all objects in the WebKit namespace
  # Holds the reference from an FFI::Pointer in a property
  # and delegates to the object returned from get_property('real')
  # as this setups signals and such
  class GLibProvider < GLib::Object
    type_register
    spec = GLib::Param::Object.new 'real','real','',GLib::Type['GtkObject'],3
    install_property spec,1
    
    attr_accessor :real
    # @param ptr [FFI::Pointer,Object#to_ptr] the FFI::Pointer to provide for
    def initialize ptr
      super()
      set_real ptr
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
    
    # will connect signals to the providee
    def signal_connect *o,&b
      get_property('real').signal_connect *o,&b
    end
  end
end
