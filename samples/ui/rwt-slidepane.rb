if __FILE__ == $0
  p Dir.getwd
  $: << Dir.getwd
  require 'rwt2'
end

module Rwt
  class SlidePane < HBox
    alias :'add!' :add
    undef :add
    
    def initialize *o
      super
      add! Rwt::Object.new(self,:size=>[0,0]),0,0
      children[0].style.minWidth=''
    end
    
    def add1 o
      raise if @_add1
      add! o,1,true

      @_add1 = true
      
      removeChild(children[0].element)   
      add! @handle = Rwt::Drawable.new(self,:size=>[8,1],:style=>STYLE::FLAT),0,true

      if @_add2
        replaceChild(o.element,children[1].element)
        appendChild(children[1].element)
        @children = [o,@handle,children[1]]
      else
        @children=[o]
      end
      
      @handle.style.minWidth="3px"
      init_handle
      show if @shown
      @handle.hide unless (@_add1 && @_add2) || !@handle
    end
    
    def add2 o
      raise if @_add2
      add! o,1,true
      @_add2=true
      show if @shown
      @handle.hide unless (@_add1 and @_add2) || !@handle
    end
    
    def show
      super
      @handle.hide unless (@_add1 && @_add2) || !@handle
    end
    
    private
    def init_handle
      @handle.extend Rwt::Draggable
      
      @handle.dragBegin=proc do
        @handle.ownerDocument.documentElement.style.cursor='move'
        true
      end
      
      @handle.dragEnd=proc do
        @handle.ownerDocument.documentElement.style.cursor='auto'
        true
      end
      
      @handle.drag = JS.execute_script(context,"""
        this.dragNative=function(g,nx,ny,cx,cy) {
          x = document.defaultView.getComputedStyle(this.previousSibling, '').getPropertyValue('width') ;

          x = parseInt(x);
          this.previousSibling.style.width = (x+cx)+'px';
          x = document.defaultView.getComputedStyle(this.nextSibling, '').getPropertyValue('width') ;

          x = parseInt(x);
          this.nextSibling.style.width = (x-cx)+'px';
          return false;
        };this.dragNative;
      """,@handle.element)
    end
  end
end

STYLE = Rwt::STYLE

if __FILE__ == $0
 def example1 document
  root = Rwt::UI::Collection.new(document)
  document.body.innerHTML="<div id=test style='width:800px;height:800px;background-color:#ebebeb;'></div>"
  
  r=Rwt::SlidePane.new(root.find(:test)[0],:size=>[200,300],:style=>STYLE::FIXED|STYLE::BORDER_ROUND_TOP|STYLE::FLAT)

  r.add2 b=Rwt::Button.new(r,'ggfffg',:size=>[1,1])
  b.click do
    r.add1 Rwt::Button.new(r,'ggg',:size=>[1,1]) unless r.children.length == 3 
  end
  r.show
  
  r1=Rwt::SlidePane.new(root.find(:test)[0],:size=>[200,300],:position=>[230,0],:style=>STYLE::FIXED|STYLE::BORDER_ROUND_TOP|STYLE::FLAT)

  r1.add2 b1=Rwt::Button.new(r1,'ggfffg',:size=>[1,1])
  b1.click do
    r1.add1 Rwt::Button.new(r1,'ggg',:size=>[1,1]) unless r1.children.length == 3 
  end
  r1.show  
 end
 
 w = Gtk::Window.new 0
 v = WebKit::WebView.new
 w.add v
 v.load_html_string "<html><body style='width:800px;'></body></html>",nil
 
 v.signal_connect('load-finished') do |orw,f|
   example1 f.get_global_context.get_global_object.document
 end
 
 w.signal_connect("delete-event") do
   Gtk.main_quit
 end
 
 w.show_all
 
 Gtk.main
end

