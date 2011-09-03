require 'rubygems'
require 'ffi'

require 'JS'
require 'JS/props2methods'
require 'JS/webkit'

require 'JS/resource'
require '/home/ppibburr/git/ruby_js/src/hard_code/rwt'

require 'tab'
w = Gtk::Window.new()
v = WebKit::WebView.new

v.load_html_string("""<!doctype html><html><body><div id=foo height=500 width=300></div><div id=bar></div> <div id=moof style='position: relative;float: left'>
</div></body></html>""",nil)
w.add v
w.resize(600,400)
w.show_all

def on_webview_load_finished ctx
  globj = ctx.get_global_object
  doc = globj['document']
  
  Rwt.init doc
  
  JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/tab.css")

  uw=Rwt::Window.new(doc.get_element_by_id('bar'),"Core example",:position=>[15,35],:size=>[300,230])
  uw.add b=Rwt::Container.new(uw)   
  
  mb = Rwt::Menubar.from_array(b,[
    ['File',[
      ['New',[
        'Blank',
        'From Template']],
      'Open',
      'Quit']
    ],
    ['Edit',[
      'Select All',
      'Copy',
      'Paste',
      'Preferences']
    ],
    ['Help',
      ['About']
    ]
  ],:size=>[-1,25])

  b.add mb

  b.add Rwt::Label.new(b,"""Some text to demonstrate a
   multiline area of formatted text that
   etc ...
  """,:size=>[-1,50],:position=>[0,25])
  b.add Rwt::HRule.new(b,:position=>[0,88]) 
  b.add Rwt::Entry.new(b,:position=>[0,102])
  b.add Rwt::TextView.new(b,File.read(__FILE__),:position=>[0,128])
  uw.show

  tw = Rwt::Window.new(doc.get_element_by_id('foo'),"Table example",:size=>[400,200],:position=>[365,35])

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
  

  p mb.element.clientHeight
  
  tb=Rwt::Tabbed.new(doc.body,:size=>[400,300])
  for i in 1..15
    tb.add "Page #{i}"
  end
  pg = tb.add "Here"
  p tb.tab_bar.inner.element.properties.sort
  
  
  tb.show
end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |yv,f|
  on_webview_load_finished(f.get_global_context)
end

Gtk.main
