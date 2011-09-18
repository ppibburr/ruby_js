if __FILE__ == $0
  require 'rwt2'
end

module Rwt
  class Button < Drawable
    def initialize parent,text='',*o
      super parent,*o

      style['text-align'] = 'center'
      style['vertical-align']='center'
      style['font-family']="arial,helvetica,sans-serif"
      style['font-size']='11px'
      self.innerText=text
      
      set_style STYLE::FLAT
      @_border.round 10
      @_shadow.inset
      style.padding = "2px"
      style['-webkit-box-shadow']=''
      style['border'] = 'none'
      
      collection.on("mouseover") do
        @_shadow.inset
        @_border.init
        style['background-color']="eeefff"
      end
      
      collection.on("mouseout") do
        style['background-color']="#{@_bgc}"
        style['-webkit-box-shadow']=''
        style['border'] = 'none'        
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
  root = Rwt::UI::Collection.new(document)
  document.body.innerHTML="<div id=test style='width:100%;height:100%;background:-webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(208,228,247,1)), color-stop(24%,rgba(115,177,231,1)), color-stop(50%,rgba(10,119,213,1)), color-stop(79%,rgba(83,159,225,1)), color-stop(100%,rgba(135,188,234,1)));'></div>"
  2.times do
  r=Rwt::VBox.new(root.find(:test)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::FIXED|STYLE::BORDER_ROUND_TOP|STYLE::FLAT)
  r.add b=Rwt::Drawable.new(r,:size=>[-1,20],:style=>STYLE::BORDER_ROUND_TOP|STYLE::FLAT),0,1
  r.style.cursor = 'default'
  
  b.style['background']="-webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(216,224,222,1)), color-stop(22%,rgba(174,191,188,1)), color-stop(33%,rgba(153,175,171,1)), color-stop(50%,rgba(142,166,162,1)), color-stop(67%,rgba(130,157,152,1)), color-stop(82%,rgba(78,92,90,1)), color-stop(100%,rgba(14,14,14,1)))"
  b.innerText='Window Example - Rwt'
  b.style.color = '#ebebeb'
  b.style['font-size']='14px'
  b.style['text-align']='center'
  b.style.cursor = 'move'
  b.extend Rwt::Draggable
  b.set_dragged r
  
  r.add hbox=Rwt::HBox.new(r,:size=>[-1,20],:style=>STYLE::FLAT),0,1 
  
  8.times do
    hbox.add b=Rwt::Button.new(hbox,"Click me",:size=>[20,20]),1.0
    b.click do
      document.context.get_global_object.alert(" ... ")
    end    
  end
  hbox.add b=Rwt::Button.new(hbox,">>",:size=>[20,20]),1.1
  
  r.add bh = Rwt::HBox.new(r,:size=>[0,0]),0,1
  bh.add Rwt::Drawable.new(bh,:size=>[1,0]),1 
  o=Rwt::Drawable.new(bh,:size=>[0,0])
  p o.style.cssText=o.style.cssText+"""
	border-bottom: 20px solid silver; 
	border-left: 20px solid transparent;  
  """
  bh.add o,0
  bh.style.top = (r.clientHeight-bh.offsetTop-20).to_s+"px"

  o.style.cursor = 'se-resize'
  o.extend Rwt::Draggable
  o.drag = proc do |t,g,nx,ny,cx,cy|
    r.grow cx,cy
    bh.style.top = (bh.style.top.to_f+cy).to_s+"px" #if cy!=0
    false
  end

  r.show
  end
 end
 
 w = Gtk::Window.new
 v = WebKit::WebView.new
 w.set_size_request(1024,600)
 w.add v
 v.load_html_string "<html><body style='width:100%;'></body></html>",nil
 
 v.signal_connect('load-finished') do |o,f|
   example1 f.get_global_context.get_global_object.document
 end
 
 w.signal_connect("delete-event") do
   Gtk.main_quit
 end
 
 w.show_all
 
 Gtk.main
end
