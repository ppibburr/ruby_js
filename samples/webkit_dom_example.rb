
#       webkit_dom_example.rb
             
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
require 'ffi'

require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')
require File.join(File.dirname(__FILE__),'..','lib','JS','webkit')
require "rwt"
require 'script'

w = Gtk::Window.new()
v = WebKit::WebView.new

v.load_html_string("""<!doctype html><html><body><div id=foo height=500 width=300></div><div id=bar></div></body></html>""",nil)
w.add v
w.resize(800,600)
w.show_all



def ruby_do_dom ctx
  globj = ctx.get_global_object
  doc = globj['document']
  
  JS::Style.load doc,"rwt_theme_default.css"
  
  uw=Rwt::Window.new(doc.get_element_by_id('bar'),"Core example",:position=>[15,15],:size=>[300,230])
  uw.add b=Rwt::Container.new(uw)   
  b.add Rwt::Label.new(b,"""Some text to demonstrate a
   multiline area of formatted text that
   etc ...
  """,:size=>[-1,50])
  b.add Rwt::HRule.new(b,:position=>[0,63]) 
  b.add Rwt::Entry.new(b,:position=>[0,77])
  b.add Rwt::TextView.new(b,File.read(__FILE__),:position=>[0,103])
  uw.show

  tw = Rwt::Window.new(doc.get_element_by_id('foo'),"Table example",:size=>[400,200],:position=>[365,15])

  t=Rwt::Table.new tw,:columns=>[
    {:label=>"Item"},
    {:label=>"Description"},
    {:label=>"Part No",:view=>Rwt::Table::Column::NUMBER,:sort=>'DESC'}
  ]
  
  ary = []
  
  for i in 1..100
    ary << [i,"item #{i}",rand(10000)]
  end  
  
  t.data(ary)
  
  tw.add t
  tw.show
end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |yv,f|
  ruby_do_dom(f.get_global_context)
end

Gtk.main

