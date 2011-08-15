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
  ele = document.createElement.call('div')
  ele.innerHTML = "Click any where ..."
  document.body.appendChild.call(ele)
  
  if document.body.getElementsByTagName.call('div')[0].to_ptr == ele.to_ptr
	  if ele.innerHTML == "Click any where ..."
		Gtk.main_quit
		puts "#{File.basename(__FILE__)} passed"
	  else
		puts "#{File.basename(__FILE__)} test 2 failed"
		Gtk.main_quit
		exit(1)
	  end
  else
    puts "#{File.basename(__FILE__)} test 1 failed"
    Gtk.main(quit)
    exit(1)
  end
  
rescue => e
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
