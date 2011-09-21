if __FILE__ == $0
  p Dir.getwd
  $: << Dir.getwd
  require 'rwt2'
end

module Rwt
  STYLE::RESIZABLE = STYLE::SHADOW_INSET*2*2
  module Resizable
    def set_style flags=0
      super
      if flags&STYLE::RESIZABLE == STYLE::RESIZABLE
        style['overflow']='hidden'
        make_resizable
      end
    end

    def make_hint
      hint=Rwt::Drawable.new(self,:style=>STYLE::BORDER_ROUND)
      hint.style['z-index']=100
      hint.style['position']="absolute"
      hint.style['border-style']="dashed"
      hint.hide 
      hint
    end
    
    def make_resizable
      @_grip_box = Rwt::HBox.new(self,:style=>STYLE::BOTTOM)
      @_grip_box.add Rwt::Drawable(@_grip_box,:size=>[1,0]),1
      @_grip_box.add @_size_grip=o=Rwt::Drawable.new(@_grip_box,:size=>[0,0]),0
      o.style.cssText=o.style.cssText+"""
        border-bottom: 20px solid silver; 
        border-left: 20px solid transparent;  
      """
    end
    
    def show
      r=super
      grip_box.show
      r
    end
    
    def on_resize
      grip_box.show
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
  
  r=Rwt::VBox.new(root.find(:test)[0],:size=>[200,300],:style=>STYLE::FIXED|STYLE::BORDER_ROUND_TOP|STYLE::FLAT)
  r.add c=Rwt::Drawable.new(r),1,1
  r.add bh = Rwt::HBox.new(r,:size=>[0,0]),0,1
  
  bh.add Rwt::Drawable.new(bh,:size=>[1,0]),1 
  bh.add o=Rwt::Drawable.new(bh,:size=>[0,0]),0
  o.style.cssText=o.style.cssText+"""
    border-bottom: 20px solid silver; 
    border-left: 20px solid transparent;  
  """
  dh=JS.execute_script(document.context,File.read("dnd.js"))
  bh.style.top = (r.clientHeight-bh.offsetTop-20).to_s+"px"

  hint = o.element.hint = make_hint( root.find(:test)[0])

  hint.style.cursor = o.style.cursor = 'se-resize'

  Rwt::UI::DragHandler.attach o

  o.dragBegin = proc do
    Rwt::UI::DragHandler.of(o).grip = hint.element
    hint.show
    hint.set_size r.get_size 
    hint.set_position [r.offsetLeft,r.offsetTop]   
    true
  end

  hint.dragBegin = proc do |*d| true end
  
  hint.dragEnd = proc do
   r.set_size hint.get_size
   hint.hide
   Rwt::UI::DragHandler.of(o).grip = o.element
   Rwt::UI::DragHandler.of(o).dragged = r.element
   true
  end 
   
  ### slow-ish! looks laggy
  # hint.drag = proc do |q,g,nx,ny,cx,cy|
  #   hint.grow_x cx if cx!=0
  #   hint.grow_y cy if cy!=0
  #   false
  # end  
  ###
  
  ### faster, looks decent
   hint.drag = JS.execute_script(document.context,"""
    f=function(g,nx,ny,cx,cy) {
      this.style.width = (parseInt(this.style.width)+cx)+'px';
      this.style.height = (parseInt(this.style.height)+cy)+'px';
      return false;
    };
    f;
  """,hint.element)
  ###
  
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
