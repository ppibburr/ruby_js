require 'rwt-controls'
if __FILE__ == $0
  require 'rubygems'
  require 'ijs'
  require 'rwt-controls'
end

module Rwt
  STYLE::RESIZABLE = STYLE::SHADOW_INSET*2*2
  module Resizable
    def set_style flags=0
      super
      if flags&STYLE::RESIZABLE == STYLE::RESIZABLE
        style['resize']='both'
        style['overflow']='auto'
        style['min-width']='20px'
        style['min-height']='20px'
      end
    end
  end
end

STYLE = Rwt::STYLE

if __FILE__ == $0
 def example1 document
  root = UI::Collection.new(document)
  document.body.innerHTML="<div id=test style='width:800px;height:800px;background-color:#ebebeb;'></div>"
  
  r=Rwt::VBox.new(root.find(:test)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::FIXED|STYLE::BORDER_ROUND_LEFT|STYLE::FLAT)
  r.add b=Rwt::Button.new(r,"Click me",:size=>[-1,20]),0,1
  r.add hbox=Rwt::HBox.new(r,:size=>[-1,20]),0,1 
  
  5.times do
    hbox.add b=Rwt::Button.new(hbox,"Click me",:size=>[100,20]),1
    b.click do
      document.context.get_global_object.alert(" ... ")
    end    
  end
  r.extend Rwt::Resizable
  r.set_style r._style|STYLE::RESIZABLE
  r.show
 end
 
 w = Gtk::Window.new
 v = WebKit::WebView.new
 w.add v
 v.load_html_string "<html><body style='width:800px;'></body></html>",nil
 
 v.signal_connect('load-finished') do |o,f|
   example1 f.get_global_context.get_global_object.document
 end
 
 w.signal_connect("delete-event") do
   Gtk.main_quit
 end
 
 w.show_all
 
 Gtk.main
end
