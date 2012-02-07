
require 'rubygems'
require 'ffi'

require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')
require File.join(File.dirname(__FILE__),'..','lib','JS','webkit')

w = Gtk::Window.new(:toplevel)
v = WebKit::WebView.new

v.load_html_string("""<!doctype html><html><body><div id=foo height=500 width=300></div><div id=bar></div></body></html>""",nil)
w.add v
w.resize(800,600)
w.show_all



def ruby_do_dom ctx
  globj = ctx.get_global_object
  doc = globj['document']
end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |yv,f|
  ruby_do_dom(f.get_global_context)
end

Gtk.main

