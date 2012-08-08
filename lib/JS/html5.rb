
#       html5.rb
             
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
require 'gir_ffi'
require 'JS/base'

GirFFI.setup :WebKit,'3.0'

module WebKit::Lib
  attach_function :webkit_web_frame_get_global_context,[:pointer],:pointer
end

c = WebKit::WebFrame
c.class_eval do
  define_method :get_global_context do
    ptr = WebKit::Lib.webkit_web_frame_get_global_context(self)
    p ptr
    JS::GlobalContext.new(:pointer=>ptr)
  end
  alias :global_context :get_global_context
  define_method :get_global_object do
    global_context.get_global_object
  end
  alias :global_object :get_global_object
end

module GLib::Lib
  attach_function :g_list_nth_data,[:pointer,:int],:pointer
  attach_function :g_list_length,[:pointer],:int
end

c = GObject::Object
c.class_eval do
  define_method :signal_connect do |*o,&b|
    GObject.signal_connect self,*o,&b
  end
end

c = GLib::List
c.class_eval do
  def nth_data i
    pt = GLib::Lib.g_list_nth_data self,i
  end
  def length
    GLib::Lib::g_list_length self
  end
end


c = Gtk::Menu
c.class_eval do
  def children
    glist = get_children
    a = []
    for i in 1..glist.length
      q = glist.nth_data i-1
      a << GirFFI::ArgHelper.object_pointer_to_object(q)
    end
    a
  end
end
