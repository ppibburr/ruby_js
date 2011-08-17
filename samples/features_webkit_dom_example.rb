require 'rubygems'
require 'gir_ffi'

require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')
GirFFI.setup "Gtk"

Gtk.init

w = Gtk::Window.new(:toplevel)
v = WebKit::WebView.new

v.load_html_string("<html><body></body></html>",nil)
w.add v
w.show_all


def ruby_do_dom ctx
  globj = ctx.get_global_object
  document = globj.document

  document.body.onclick = proc do |this,*o|
    globj.alert.call("events!")
    nil;
  end


  body = document.getElementsByTagName.call('body')[0]
  ele = document.createElement.call('div')
  ele.innerHTML = "Click any where ..."
  
  body.appendChild.call(ele)
  
  globj.alert.call("Hello World")
end

GObject.signal_connect(w,'delete-event') do 
  Gtk.main_quit
end

GObject.signal_connect(v,'load-finished') do |v,f|
  ruby_do_dom(f.get_global_context)
end

Gtk.main
