require 'rwt-box'
if __FILE__ == $0
  require 'rubygems'
  require 'ijs'
  require 'rwt-box'
end

module Rwt
  class Button < Drawable
    def initialize parent,text='',*o
      super parent,*o

      style['text-align'] = 'center'
      style['vertical-align']='center'
      
      self.innerText=text
      
      set_style STYLE::FLAT
      
      collection.on("mouseover") do
        @_bgc = get_css_style("background-color")
        style['background-color']="#F7F7F9"
      end
      
      collection.on("mouseout") do
        style['background-color']="#{@_bgc}"
      end      
    end
    
    def click &b
      if b
        collection.on('click',&b)
      else
        collection.fire('click')
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
