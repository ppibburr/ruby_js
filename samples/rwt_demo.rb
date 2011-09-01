require 'rubygems'
require 'ffi'

require 'JS'
require 'JS/props2methods'
require 'JS/webkit'

require 'JS/resource'
require "JS/rwt"


w = Gtk::Window.new()
v = WebKit::WebView.new

v.load_html_string("""<!doctype html><html><body><div id=foo height=500 width=300></div><div id=bar></div></body></html>""",nil)
w.add v
w.resize(600,400)
w.show_all

def on_webview_load_finished ctx
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
  
  rc = Rwt::Collection.new(doc)
  p rc[".panel",".label","#foo"]
end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |yv,f|
  on_webview_load_finished(f.get_global_context)
end

Gtk.main
