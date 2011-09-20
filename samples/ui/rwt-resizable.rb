if __FILE__ == $0
  p Dir.getwd
  $: << Dir.getwd
  require 'rwt2'
end

module Rwt
  STYLE::RESIZABLE = STYLE::BOTTOM*2
  
  class SizeGripBox < HBox
    def initialize sizee
      @sizee = sizee
      super sizee.ownerDocument.body,:size=>[0,0],:style=>STYLE::FIXED
    end
    
    def show
      super
      x = @sizee.offsetLeft
      y = @sizee.offsetLeft
      y = y + @sizee.get_css_style("height").to_f - clientHeight
      set_position [x,y]
      
      w = @sizee.get_css_style("width").to_f
      set_size [w,0]
    end
  end
  
  module Resizable
    def set_style flags=0
      super
      if flags&STYLE::RESIZABLE == STYLE::RESIZABLE
        style['overflow']='hidden'
        make_resizable
      end
    end

    def make_hint
      hint=Rwt::Drawable.new(self.parent,:style=>STYLE::BORDER_ROUND)
      hint.style['z-index']=100
      hint.style['position']="absolute"
      hint.style['border-style']="dashed"
      hint.style.cursor = 'se-resize'
      hint.hide 
      hint
    end
    
    def make_resizable
      return @_grip_box if is_resizable?
      @_grip_box = Rwt::SizeGripBox.new(self)
      @_grip_box.add Rwt::Drawable.new(@_grip_box,:size=>[1,0]),1
      @_grip_box.add @_size_grip=o=Rwt::Drawable.new(@_grip_box,:size=>[0,0]),0
      o.style.cssText=o.style.cssText+"""
        border-bottom: 20px solid silver; 
        border-left: 20px solid transparent;
        cursor: se-resize;  
        z-index: 10000;
      """
      
      @_is_resizable = true
      
      @_size_hint = make_hint
      
      Rwt::UI::DragHandler.attach(o)
      
      o.dragBegin = proc do
        @_size_hint.show
        @_size_hint.set_size self.get_size
        @_size_hint.set_position [self.offsetLeft,self.offsetTop]
        Rwt::UI::DragHandler.of(o).grip = Rwt::UI::DragHandler.of(o).dragged = @_size_hint.element
        true
      end
      
      @_size_hint.dragBegin = proc do true end
      
      @_size_hint.dragEnd = proc do
        @_size_hint.hide
        Rwt::UI::DragHandler.of(@_size_hint).grip = Rwt::UI::DragHandler.of(@_size_hint).dragged = o.element
        on_resize(@_size_hint.get_size)
        true
      end
      
      @_size_hint.drag = JS.execute_script(context,"""
        f=function(g,nx,ny,cx,cy) {
          this.style.width = (parseInt(this.style.width)+cx)+'px';
          this.style.height = (parseInt(this.style.height)+cy)+'px';
          return false;
        };
        f;
      """)
    end
    
    def is_resizable?
      @_is_resizable
    end
    
    def show
      r=super
      @_grip_box.show
      r
    end
    
    # Just resize the object
    # children/contents resizing should be implemented in the class implemeting this module
    # If the implementing instance is a subclass of Rwt::Box, content resizing should be automatic
    #   (the preffered way)
    def on_resize size
      set_size size
      @_grip_box.show
    end
    
    def self.extended q
      q.set_style q.instance_variable_get("@_style")
    end
  end    
end

STYLE = Rwt::STYLE

if __FILE__ == $0
 def make_hint parent
  hint=Rwt::Drawable.new(parent,:style=>STYLE::BORDER_ROUND)
  hint.style['z-index']=100
  hint.style['position']="absolute"
  hint.style['border-style']="dashed"
  hint.hide 
  hint
 end
 
 def example1 document
  root = Rwt::UI::Collection.new(document)
  document.body.innerHTML="<div id=test style='width:800px;height:800px;background-color:#ebebeb;'></div>"
  
  r=Rwt::VBox.new(root.find(:test)[0],:size=>[200,300],:style=>STYLE::FIXED|STYLE::RESIZABLE|STYLE::BORDER_ROUND_TOP|STYLE::FLAT)
  r.extend Rwt::Resizable
  r.add Rwt::Button.new(r,'ggg',:size=>[1,1]),1,1
  r.show
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
