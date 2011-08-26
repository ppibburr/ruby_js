require 'gtk2'

module GLib
  class Object
    alias :sig_con :signal_connect 
    # correctly yields objects in namespace WebKit::<aClassName>
    # that include GLib::Object functionalty
    def signal_connect *o,&b
      sig_con *o do |*o|
        b.call( o.map do |q|
          if q.class.inspect =~ /#<Class/
            if q.gtype.to_s =~ /WebKit(.*)/
              begin 
                wk = WebKit.wrap_return_from_standard q,$1
                wk
              rescue => e
                raise e
                q
              end
            else
              q
            end
          else
            q
          end
        end) 
      end
    end
  end
end

module GLib
  # for setting properties for the WebKit::GLibProvider
  module IKE
    extend FFI::Library
    ffi_lib 'gobject-2.0'
    
    attach_function :g_value_init,[:pointer,:int],:pointer
    attach_function :g_value_set_object,[:pointer,:pointer],:void
    attach_function :g_type_from_name,[:string],:int
    attach_function :g_object_set_property,[:pointer,:string,:pointer],:bool
  end
  
  # for setting properties for the WebKit::GLibProvider  
  class Value
    def initialize
      @ptr = FFI::MemoryPointer.new(:pointer,8)
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


module Gtk
  # patch in adding a FFI::Pointer to a Gtk::Container
  module IKE
    extend FFI::Library
    ffi_lib(JS::Config[:WebKit][:Gtk][:lib] || 'gtk-x11-2.0')
    attach_function :gtk_container_add,[:pointer,:pointer],:void
    attach_function :gtk_main,[],:void
  end
  
  alias :main! :main
  # when using standard Gtk.main, Events for DOM Elements using ruby defined functions hang
  # this cures it
  def self.main
    Gtk::IKE.gtk_main
  end
end

class Gtk::Container
  # adds the FFI::Pointer to the Gtk::Container
  def add_webview w
    Gtk::IKE.gtk_container_add self,w
  end
 
  alias :real_add :add
  
  def add q
    if q.is_a? WebKit::WebView
      add_webview q
    else
      real_add q
    end
  end
  
  # creates a FFI::Pointer from an instance of Gtk::Container
  def get_pointer
    if inspect =~ /ptr=0x([0-9a-z]+)/
      FFI::Pointer.new $1.to_i(16)
    else
      raise
    end
  end
  
  alias :to_ptr :get_pointer
end

module WebKit
  # A WebKit::<Object> from an q=(instance of Class)
  def self.wrap_return_from_standard q,klass
    raise unless q.inspect =~ /ptr\=0x([0-9a-z]+)/
    
    adr = $1.to_i(16)
    wk = eval("WebKit::#{klass}").new(:ptr => FFI::Pointer.new(adr) )
    
    wk
  end
end
