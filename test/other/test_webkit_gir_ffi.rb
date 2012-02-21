require File.join(File.dirname(__FILE__),'..','..','lib','JS')
require File.join(File.dirname(__FILE__),'..','..','lib','JS/props2methods')
require File.join(File.dirname(__FILE__),'..','..','lib','JS','webkit_gir_ffi')
Gtk.init []
w = Gtk::Window.new
v = WebKit::WebView.new
w.add v
v.load_html_string "foo",""
v.signal_connect "load-finished" do |view,frame|
  ctx=frame.get_global_context
  globj = ctx.get_global_object
  window = globj.window
end

v.signal_connect "window-object-cleared" do |*o|
  p o
  Gtk.main_quit
end

w.show_all
Gtk.main
