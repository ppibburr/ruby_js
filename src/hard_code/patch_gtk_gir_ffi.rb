Gtk
Gtk::Object
class Gtk::Object
	def signal_connect n,&b
	  GObject.signal_connect(self,n,&b)
	end
end
GLib
module GLib
  Object = GObject::Object
end
Gtk::Window
class Gtk::Window
  class << self
    alias :real_new :new
  end
  
  @c="""def self.new *o
    if o.empty?
      o << :toplevel
    end
    r=real_new *o
    Gtk::Window.define_new
    r
  end"""
  def self.define_new
    class_eval @c
  end
  define_new
end
module Gtk
  def self.main *o
    super *o
    nil
  end
  def self.main_quit *o
    super *o
    nil
  end
end
