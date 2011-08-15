require 'rubygems'
require 'gir_ffi'

require File.join(File.dirname(__FILE__),'..','lib','JS')


GirFFI.setup "Gtk"

Gtk.init

w = Gtk::Window.new(:toplevel)
v = WebKit::WebView.new

v.load_html_string("<html><body></body></html>",nil)
w.add v
w.show_all


def ruby_do_dom ctx
  globj = ctx.get_global_object

  doc = globj['document']
  body = doc['getElementsByTagName'].call('body')[0]
  ele = doc['createElement'].call('div')
  ele['innerHTML'] = "Click any where ..."
  body['appendChild'].call(ele)
  
  if ele['innerHTML'] == "Click any where ..."
    Gtk.main_quit
    puts "#{File.basename(__FILE__)} passed"
  else
    Gtk.main_quit
    exit(1)
  end
  
rescue 
  puts "something went wrong"
  exit(1)
end

GObject.signal_connect(w,'delete-event') do 
  Gtk.main_quit
end

GObject.signal_connect(v,'load-finished') do |v,f|
  ruby_do_dom(f.get_global_context)
end

Gtk.main
