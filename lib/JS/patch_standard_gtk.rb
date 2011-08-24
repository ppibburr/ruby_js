
#       patch_standard_gtk.rb
             
#		(The MIT License)
#
#        Copyright 2011 Matt Mesanko <tulnor@linuxwaves.com>
#
#		Permission is hereby granted, free of charge, to any person obtaining
#		a copy of this software and associated documentation files (the
#		'Software'), to deal in the Software without restriction, including
#		without limitation the rights to use, copy, modify, merge, publish,
#		distribute, sublicense, and/or sell copies of the Software, and to
#		permit persons to whom the Software is furnished to do so, subject to
#		the following conditions:
#
#		The above copyright notice and this permission notice shall be
#		included in all copies or substantial portions of the Software.
#
#		THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
#		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
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
