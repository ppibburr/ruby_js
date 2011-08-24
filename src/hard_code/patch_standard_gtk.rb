require 'gtk2'
module GObject
  module Lib
    extend FFI::Library
    CALLBACKS = []
    ffi_lib "gobject-2.0"
    callback :GCallback, [], :void
    enum :GConnectFlags, [:AFTER, (1<<0), :SWAPPED, (1<<1)]

    attach_function :g_signal_connect_data, [:pointer, :string, :GCallback,
      :pointer, :pointer, :GConnectFlags], :ulong
    attach_function :g_thread_init,[],:void
  end

  def self.signal_connect_data gobject, signal, prc, data, destroy_data, connect_flags
    Lib::CALLBACKS << prc
    Lib.g_signal_connect_data gobject, signal, prc, data, destroy_data, connect_flags
  end
end

module Gtk
  module IKE
    extend FFI::Library
    ffi_lib(JS::Config[:WebKit][:Gtk][:lib] || 'gtk-x11-2.0')
    attach_function :gtk_container_add,[:pointer,:pointer],:void
    attach_function :gtk_init,[:int,:pointer],:void
    attach_function :gtk_main,[:pointer,:pointer],:void
  end
  
  class << self
    alias :real_main :main
  end
  
  def self.main
    IKE.gtk_main nil,nil
  end
end

class Gtk::Container
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
  
  def get_pointer
    if inspect =~ /ptr=0x([0-9a-z]+)/
      FFI::Pointer.new $1.to_i(16)
    else
      raise
    end
  end
  
  alias :to_ptr :get_pointer
end
