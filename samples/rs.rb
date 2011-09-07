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
  

  vb=Rwt::VBox.new(doc.body,:size=>[100,50])
  vb.add handle=Rwt::HBox.new(vb,:size=>[20,20]),1,'20px','20px'
  handle.style['background-color']='blue'
  vb.style.resize='both'
  vb.style.overflow='hidden'
  Rwt::Collection.new(vb,[vb]).add_class "listen_resize"
  vb.element['onresize'] = proc do
    p 1
  end
  vb.show

end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |yv,f|
  on_webview_load_finished(f.get_global_context)
end



Gtk.main
