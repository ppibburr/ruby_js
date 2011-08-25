require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','webkit')
W = Gtk::Window.new

class Provider < GLib::Object
  type_register
  spec = GLib::Param::Object.new 'real','real','',GLib::Type['GtkObject'],3
  install_property spec,1
  attr_accessor :real
  def initialize
    super
  end
  
  def to_ptr
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
    GLib::IKE.g_object_set_property to_ptr,'real',v 
  end
end


module GLib
  module IKE
    extend FFI::Library
    ffi_lib 'gobject-2.0'
    
    attach_function :g_value_init,[:pointer,:int],:pointer
    attach_function :g_value_set_object,[:pointer,:pointer],:void
    attach_function :g_type_from_name,[:string],:int
    attach_function :g_object_set_property,[:pointer,:string,:pointer],:bool
  end
  
  class Value
    class Struct < FFI::MemoryPointer;end
    def initialize
      @ptr = Struct.new :pointer,8
    end
    
    def init type
      GLib::IKE.g_value_init @ptr,type
    end
    
    def set_object o
      GLib::IKE.g_value_set_object @ptr,o
    end
    
    def to_ptr
      @ptr
    end
  end
end

Provider.new
