if __FILE__ == $0
  require 'rwt2'
end

module Rwt
  class Box < Container
    def initialize *o
      super
      style['display']='-webkit-box'
      @_display = '-webkit-box'
    end
    
    def add o,major=0
      super(o)
      o.style.minHeight='0px'
      o.style['-webkit-box-flex']=major
      o.style['-webkit-box-sizing']= 'border-box'     
    end
  end
  
  class VBox < Box
    def initialize *o
      super
      style['-webkit-box-orient']='vertical'
    end
    
    def add o,major=0,minor=nil
      super o,major
      if minor
        o.style['width']='100%'
      end
    end
  end
  
  class HBox < Box
    def initialize *o
      super
      style['-webkit-box-orient']='horizontal'
    end 
    
    def add o,major=0,minor=nil
      super o,major
      if minor
        o.style['height']='100%'
      end
    end     
  end
end

STYLE = Rwt::STYLE

if __FILE__ == $0
 def example1 document
  root = Rwt::UI::Collection.new(document)
  document.body.innerHTML="<div id=test style='width:800px;height:800px;background-color:#ebebeb;'></div>"
  
  r=Rwt::VBox.new(root.find(:test)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::FIXED|STYLE::BORDER_ROUND_LEFT|STYLE::FLAT) 

  r.add c=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),1,true  
  r.add c1=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),1.25,true
  r.add c2=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),1.5,true
  
  r.show
  
  o=Rwt::Drawable.new(root.find(:test)[0],:size=>[250,23],:position=>[15,15],:style=>STYLE::FLAT)
  o.innerText = "GoTo: Horizontal Example"
  o.collection.on('click') do
    example2 document
    false
  end
 end
 
 def example2 document
  root = Rwt::UI::Collection.new(document)
  document.body.innerHTML="<div id=test1 style='width:800px;height:800px;background-color:#ebebeb;'></div>"
  
  r=Rwt::HBox.new(root.find(:test1)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::FIXED|STYLE::BORDER_ROUND_LEFT|STYLE::FLAT) 

  r.add c=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),1,true  
  r.add c1=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),1.25,true
  r.add c2=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),1.5,true
  
  r.show
  
  o=Rwt::Drawable.new(root.find(:test1)[0],:size=>[250,23],:position=>[15,15],:style=>STYLE::FLAT)
  o.innerText = "GoTo: Example of Both"
  o.collection.on('click') do
    example3 document
    false
  end
 end 
 
 def example3 document
  root = Rwt::UI::Collection.new(document)
  document.body.innerHTML="<div id=test2 style='width:800px;height:800px;background-color:#ebebeb;'></div>"
  
  r=Rwt::VBox.new(root.find(:test2)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::FIXED|STYLE::BORDER_ROUND_LEFT|STYLE::FLAT) 

  hba=[]
  maj=[1,1.25,1.5]

  for i in 0..2
    r.add hb=Rwt::HBox.new(r),maj[i],true
    hba << hb
  end
  
  hba.each do |c|
    for i in 0..2
      c.add Rwt::Drawable.new(c,:style=>STYLE::BORDER_ROUND|STYLE::RAISED),maj[i],true
    end
  end
  
  r.show
  
  o=Rwt::Drawable.new(root.find(:test2)[0],:size=>[250,23],:position=>[15,15],:style=>STYLE::FLAT)
  o.innerText = "GoTo: 1st Example"
  o.collection.on('click') do
    example1 document
    false
  end
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
