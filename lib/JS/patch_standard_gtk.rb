
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

module GLib
  class Object
    alias :sig_con :signal_connect 
    # correctly yields objects in namespace WebKit::<aClassName>
    # that include GLib::Object functionalty
    def signal_connect *o,&b
      sig_con *o do |*o|
        v = b.call( o.map do |q|
          if q.class.inspect =~ /#<Class/;
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
        if v.is_a?(WebKit::GLibProvider)
          v.real
        else
          v
        end
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
  class << self
    alias :main! :main
  end
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
  def self.wrap_return_from_standard q,klass,force=nil
    raise unless q.inspect =~ /ptr\=0x([0-9a-z]+)/
    
    adr = $1.to_i(16)
    if o=WebKit::GLibProvider::PTRS[adr] and !force
      return o
    end
    wk = eval("WebKit::#{klass}").new(:ptr => FFI::Pointer.new(adr) )
  end
end
