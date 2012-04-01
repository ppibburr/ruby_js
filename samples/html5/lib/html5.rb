require 'gir_ffi'
require 'JS/base'

GirFFI.setup :WebKit,'1.0'

module WebKit::Lib
  attach_function :webkit_web_frame_get_global_context,[:pointer],:pointer
end

c = WebKit::WebFrame
c.class_eval do
  define_method :get_global_context do
    ptr = WebKit::Lib.webkit_web_frame_get_global_context(self)
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
