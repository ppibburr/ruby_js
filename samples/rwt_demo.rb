require 'rubygems'
require 'ffi'

require 'JS'
require 'JS/props2methods'
require 'JS/webkit'

require 'JS/resource'
require '/home/ppibburr/git/ruby_js/src/hard_code/rwt'

require 'tab'
require 'sizing'
require 'box'
require 'button'

w = Gtk::Window.new()
v = WebKit::WebView.new

v.load_html_string("""<!doctype html><html><body><div id=foo height=500 width=300></div><div id=bar></div> <div id=moof style='position: relative;float: left'>
</div><div id=cow></div></body></html>""",nil)
w.add v
w.resize(800,600)
w.show_all
def on_item_activated *o
  p :activate_event
end

def on_webview_load_finished ctx
  globj = ctx.get_global_object
  doc = globj['document']
  rwt=Rwt::Collection.new(doc,[doc])  
  Rwt.init doc
  
  JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/tab.css")
  JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/box.css")
  JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/button.css") 
  
  uw=Rwt::Window.new(doc.get_element_by_id('bar'),"Core example",:position=>[15,35],:size=>[300,250])
  uw.add b=Rwt::Container.new(uw)   
  
  mb = Rwt::Menubar.from_array(b,[
    {:label=>"File",:children=>[
      {:label=>'New  ->',:children=>[
        {:label=>'From Template',:activate=>:on_item_activated},
        {:label=>'Blank',:id=>:blank}     
      ]},
      {:label=>'Open',:activate=>:on_item_activated},
      {:label=>'Quit',:activate=>:on_item_activated}
    ]},       
    {:label=>'Edit',:children=>[
      {:label=>'Find',:activate=>:on_item_activated},
      {:label=>'Copy',:activate=>:on_item_activated},
      {:label=>'Paste',:activate=>:on_item_activated}            
    ]},
    {:label=>'Help',:children=>[
      {:label=>'About',:activate=>:on_item_activated}
    ]}
  ],:size=>[-1,25])

  rwt.find(:blank).bind(:click) do
    on_item_activated
  end

  b.add mb
  
  

  b.add Rwt::Label.new(b,"""Some text to demonstrate a
   multiline area of formatted text that
   etc ...
  """,:size=>[-1,50],:position=>[0,25])
  b.add Rwt::HRule.new(b,:position=>[0,88]) 
  b.add Rwt::Entry.new(b,:position=>[0,102])
  b.add Rwt::TextView.new(b,File.read(__FILE__),:position=>[0,128],:size=>[-1,96])
  uw.show

  tw = Rwt::Window.new(doc.get_element_by_id('foo'),"Table example",:size=>[400,250],:position=>[380,35])

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
  
  rwt.find *[".panel",".label","#foo"]
  

  p mb.element.clientHeight

  tbw = Rwt::Window::new(doc.get_element_by_id('moof'),"TabBook Example",:size=>[300,250],:position=>[15,300])
  tb=Rwt::Tabbed.new(tbw)
  for i in 1..7
  
    pg=tb.add "Page #{i}"
    pg.add Rwt::Label.new(pg,"this is page #{i}")
  end  
  tbw.add tb
  tbw.show
  
  bw = Rwt::Window::new(doc.get_element_by_id('cow'),"Layout Example",:size=>[400,250],:position=>[380,300])
  bw.add vb=Rwt::VBox.new(bw) 
  for i in 0..3
    vb.add hb=Rwt::HBox.new(vb),i
    for ii in 0..3
      hb.add Rwt::Button.new(hb,"item #{i}:#{ii}"),ii
    end
  end
  bw.show  
  
  p Rwt::Collection.new(doc).find(".listen_resize")
end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |yv,f|
  on_webview_load_finished(f.get_global_context)
end

Gtk.main
