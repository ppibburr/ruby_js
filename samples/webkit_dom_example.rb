require 'rubygems'
require 'JS/desktop'

w = Gtk::Window.new(:toplevel)
v = WebKit::WebView.new

v.load_html_string("""<!doctype html><html><body><div id=foo>Click here ...</div></body></html>""",nil)

w.add v
w.resize(400,400)
w.show_all

def ruby_do_dom ctx
  globj = ctx.get_global_object
  document = globj.document
  document.getElementById('foo').onclick = proc do |*o| globj.alert("Click!") end
end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |yv,f|
  ruby_do_dom(f.get_global_context)
end

Gtk.main

