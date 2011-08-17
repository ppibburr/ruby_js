
#       test_webkit_dom.rb
             
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
