module WebKit
  class GLibProvider < GLib::Object
    type_register
    spec = GLib::Param::Object.new 'real','real','',GLib::Type['GtkObject'],3
    install_property spec,1
    attr_accessor :real
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
    
    def signal_connect *o,&b
      get_property('real').signal_connect *o,&b
    end
  end
end
