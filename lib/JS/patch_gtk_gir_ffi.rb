
#       patch_gtk_gir_ffi.rb
             
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
