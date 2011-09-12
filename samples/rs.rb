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
  JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/proper.css")   

  w=Rwt::Dow.new(doc.body,'',:size=>[100,100])
  vb = Rwt::VBox.new(w)
  w.add vb
  tb=Rwt::Tabbed.new(vb)
  for i in 1..7
  
    pg=tb.add "Page #{i}"
    pg.add Rwt::Label.new(pg,"this is page #{i}")
  end  
  vb.add tb,1,1
  w.show

end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |yv,f|
  on_webview_load_finished(f.get_global_context)
end



Gtk.main
