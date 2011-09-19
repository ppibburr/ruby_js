if __FILE__ == $0
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
        @lastExecThrottle = 0.500; # limit to one call every "n" msec
        @lastExec = Time.now.to_f
        @timer = nil;
        
        @_handler = proc { |t,*o|
           d=Time.now.to_f;
           if (d-@lastExec < @lastExecThrottle) #or (@handler.respond_to?(:arity) and o.length < @handler.arity)
             # This function has been called "too soon," before the allowed "rate" of twice per second
             # Set (or reset) timer so the throttled handler execution happens "n" msec from now instead
             if (@timer)
               object.context.get_global_object.window.clearTimeout(@timer);
             end
             @timer = object.context.get_global_object.window.setTimeout(proc do
               @_handler.call(t,*o.clone) 
             end, @lastExecThrottle);
             que.call *o if que
             return false; # exit
          end
          
          @lastExec = d; # update "last exec" time
          # At this point, actual handler code can be called (update positions, resize elements etc.)
          # self.callResizeHandlerFunctions();
          #p o
        
         @handler.call(*o) if @handler
         p 9;
         false
        }
        Rwt::UI::Collection.new(nil,[@object])[0][type]=@_handler
      rescue => e
        puts e
        raise e
      end
    end
  end
end

STYLE = Rwt::STYLE

if __FILE__ == $0
 def example1 document
  root = Rwt::UI::Collection.new(document)
  document.body.innerHTML="<div id=test style='width:800px;height:800px;background-color:#ebebeb;'></div>"
  
  r=Rwt::VBox.new(root.find(:test)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::FIXED|STYLE::BORDER_ROUND_TOP|STYLE::FLAT)
  r.add bh = Rwt::HBox.new(r,:size=>[0,0]),0,1
  
  bh.add Rwt::Drawable.new(bh,:size=>[1,0]),1 
  bh.add o=Rwt::Drawable.new(bh,:size=>[0,0]),0
  o.style.cssText=o.style.cssText+"""
    border-bottom: 20px solid silver; 
    border-left: 20px solid transparent;  
  """
  
  bh.style.top = (r.clientHeight-bh.offsetTop-20).to_s+"px"

  o.style.cursor = 'se-resize'
  o.extend Rwt::Draggable
  data=[0,0,0,0]
  Rwt::Resizable::EventThrottler.new(o,'drag',proc do |*o|;
   nx,ny,cx,cy = data#.map do |q| q end;p :lop
      
    p nx
    r.grow cx,cy
    data=[0,0,0,0]
    bh.style.top = (bh.style.top.to_f+cy).to_s+"px" #if cy!=0
    
    false
  end, proc do |t,*o|;
    o.each_with_index do |d,i|;
      data[i] = data[i]+d;
    end
    nil
  end)

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
