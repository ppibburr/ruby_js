require 'rubygems'
require 'ffi'

require 'JS'
require 'JS/props2methods'
require 'JS/webkit'

require 'JS/resource'
require '/home/ppibburr/git/ruby_js/src/hard_code/rwt'
require 'box'
require 'sizing'
require 'box'

require 'button'
require 'panel'
require 'layout'
require 'tab'
require 'pgroup'
require 'canvas'

class HMI
  attr_accessor :t,:tt,:vb,:trend_page,:tag_page,:display_page,:client,:trend
  def initialize collection,addr
    @collection = collection
    par=collection!.find(:app)[0]
    @vb = Rwt::VBox.new(par,:size=>[800,-1])
    vb.style['background-color']="#EEEEEF"
    mk_menu(vb)
    vb.add hb=Rwt::HBox.new(vb),1,1
    hb.add vbx=Rwt::PanelGroup.new(hb,:size=>[-1,-5]),0.2,1


    vbx.add_space(-1,2,0)  
    wi=vbx.add 'Connection Info'
    wi.add Rwt::Table.new(wi,:columns=>[
      {:label=>"Item"},
      {:label=>"Description"}
    ])
    
    vbx.add_space(-1,5,0)  
    wi=vbx.add 'Tags'
    wi.add Rwt::Table.new(wi,:columns=>[
      {:label=>"Item"},
      {:label=>"Description"}
    ])
        
    vbx.add_space(-1,5,0)  
    wi=vbx.add 'Quick Trend',false    
    wi.add c=Rwt::Canvas.new(wi,:position=>[8,15],:size=>[-1,-30])
    wi.size[1]=200   
    c.draw_line(0,0,100,100)  
          
    hb.add Rwt::VRule.new(hb),0,1
    @t=Rwt::Tabbed.new(hb)
    hb.add t,8,1  
    @tag_page = t.add("Tags")
    @trend_page = t.add("Trends")
    @display_page = t.add("Display")
    build()
  end
  
  def mk_menu par
    par.add m=Rwt::Menubar.from_array(par,[
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
        {:label=>'About',:activate=>method(:on_item_activated)}
      ]}
    ],:size=>[-1,25]),0,1
  end
  
  def build
    tag_page.add @tt=Rwt::Table.new(tag_page,:columns=>[
      {:label=>"Item"},
      {:label=>"Description"}
    ],:size=>[-1,600])
    trend_page.add Rwt::VBox.new(trend_page)
    display_page.add Rwt::VBox.new(display_page)
  end
  
  def collection!
    @collection
  end
  
  def on_item_activated *o
    p @m.className
  end
    
  def show
    @vb.resize_to *@vb.size
    @vb.show
  end
end


w = Gtk::Window.new()
v = WebKit::WebView.new

v.load_html_string("""<!doctype html><html><body><div id=app></div></body></html>""",nil)
w.add v
w.resize(800,600)
w.show_all


def on_webview_load_finished ctx


  globj = ctx.get_global_object
  doc = globj['document']
  rwt=Rwt::Collection.new(doc,[doc])  
  Rwt.init doc


  
  JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/tab.css")
  JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/box.css")
  JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/button.css") 
  JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/proper.css")   

  HMI.new(rwt,"192.1.168.20").show
end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |yv,f|
  on_webview_load_finished(f.get_global_context)
end



Gtk.main
