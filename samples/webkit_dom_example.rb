require 'rubygems'
require 'gir_ffi'

require File.join('..',File.dirname(__FILE__),'lib','JS')

GirFFI.setup "Gtk"

Gtk.init

w = Gtk::Window.new(:toplevel)
v = WebKit::WebView.new

v.load_html_string("<html><body></body></html>",nil)
w.add v
w.show_all


def ruby_do_dom ctx
  globj = ctx.get_global_object
  globj['alert'].call("Hello World")
  
  globj['document']['body']['onclick'] = JS::Object.make_function_with_callback(ctx,'foo') do |*o|
    globj['alert'].call("events!")
    nil;
  end
  
  doc = globj['document']
  body = doc['getElementsByTagName'].call('body')[0]
  ele = doc['createElement'].call('div')
  ele['innerHTML'] = "Click any where ..."
  
  body['appendChild'].call(ele)
end

GObject.signal_connect(w,'delete-event') do 
  Gtk.main_quit
end

GObject.signal_connect(v,'load-finished') do |v,f|
  ruby_do_dom(f.get_global_context)
end

Gtk.main
