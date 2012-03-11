require 'ffi-gtk2'
require File.join(File.dirname(__FILE__),"nice_gtk_ffi_overloads.rb")

G_OBJECT = GObject
G_OBJECT_LIB = GObject::Lib
G_T_K = Gtk
GTK_LIB = Gtk::Lib

self.class.class_eval do
  const_set :Gtk,Module.new
end

class GObj < BasicObject
  include ::Kernel
  def self.init go
    @@_g_object_ = go
  end
  def self.method_missing m,*o,&b
	@@_g_object_.send(m,*o,&b)
  end
  def method_missing m,*o,&b
	@_g_object_.send(m,*o,&b)
  end
  def initialize *o,&b
    @_g_object_ = @@_g_object_.new *o,&b
  end
end

module Gtk
  Lib = GTK_LIB
  def self.const_missing c
    q = G_T_K.const_get(c)
    if q.is_a?(Class)
      return setup(c,q)
    end
    q
  end
  def self.method_missing m,*o,&b
    G_T_K.send m,*o,&b
  end
  def self.setup c,q
    const_set c,t=Class.new(GObj)
    t.init q
    t  
  end
  def self.main
    G_T_K.main
    nil
  end
  def self.main_quit
    G_T_K.main_quit
  end
end

class GObject::Object
  def signal_connect s,&b
    GObject.signal_connect self,s,&b
  end
end

class Window < Gtk::Window
  def initialize foo
    @foo = foo
    super :toplevel
    puts "@foo is #{foo}"
  end
end


