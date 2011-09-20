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
      end
    end
    
    class EventThrottler
      attr_accessor :handler
      def initialize object,type,handler=nil,que=nil
        @object = object
        @handler = handler
        @lastExecThrottle = 0.048; # limit to one call every "n" msec
        @lastExec = Time.now.to_f
        @timer = nil;

        @_handler = proc { |t,g,*o|
           d=Time.now.to_f;
           if (d-@lastExec < @lastExecThrottle) #or (@handler.respond_to?(:arity) and o.length < @handler.arity)
             # This function has been called "too soon," before the allowed "rate" of twice per second
             # Set (or reset) timer so the throttled handler execution happens "n" msec from now instead
             if (@timer)
               object.context.get_global_object.window.clearTimeout(@timer);
             end
             @timer = object.context.get_global_object.window.setTimeout(proc do
               @_handler.call(t,g,*o.clone) 
             end, @lastExecThrottle);
             return false; # exit
          end
          
          @lastExec = d; # update "last exec" time
          # At this point, actual handler code can be called (update positions, resize elements etc.)
          # self.callResizeHandlerFunctions();
          #p o
         @handler.call(t,g,*o) if @handler
         false
        }
        Rwt::UI::Collection.new(nil,[@object])[0][type]=@handler
      rescue => e
        puts e
        raise e
      end
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
    Rwt::UI::DragHandler.of(o).dragged=hint.element
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
    var f=function(g,nx,ny,cx,cy) {
      this.style.width = (parseInt(this.style.width)+cx)+'px';
      this.style.height = (parseInt(this.style.height)+cy)+'px';
      return false;
    };
    f;
  """)
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
