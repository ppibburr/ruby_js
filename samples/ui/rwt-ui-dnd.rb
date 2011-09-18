module Rwt
  module UI
    class DragHandler
      attr_reader :grip
      attr_accessor :dragged
      # public method. Attach drag handler to an element.
      def initialize grip,drag=nil
        @grip = grip
        @dragged = drag||=@grip
        grip.onmousedown = method(:dragBegin);

        # callbacks
        grip.dragBegin = proc do true end
        grip.drag = proc do true end
        grip.dragEnd = proc do true end
      end
     
     
      # private method. Begin drag process.
      def dragBegin this,e
        x = dragged.style.left.to_f;
        y = dragged.style.top.to_f;
     
        return false if !grip.dragBegin(grip, x, y);      
     
        e = grip.context.get_global_object.window.event if !e.is_a?(JS::Object);
        dragged.mouseX = e.clientX;
        dragged.mouseY = e.clientY;
     
        grip.ownerDocument.onmousemove = method(:drag);
        grip.ownerDocument.onmouseup = method(:dragEnd);
        return false;
      end
     
     
      # private method. Drag (move) element.
      def drag this,e 
        x = dragged.style.left.to_f;
        y = dragged.style.top.to_f;
        dx = e.clientX - dragged.mouseX
        dy = e.clientY - dragged.mouseY
        nx = x + (dx) 
        ny = y + (dy)
        dragged.mouseX = e.clientX;
        dragged.mouseY = e.clientY;
        return false if !grip.drag(grip, nx,ny,dx, dy); 
     
        e = grip.context.get_global_object.window.event if !e.is_a?(JS::Object)
        dragged.style.left = (nx).to_s + 'px';
        dragged.style.top = (ny).to_s + 'px';
     
        return false;
      end
     
     
      # private method. Stop drag process.
      def dragEnd *o
        x = dragged.style.left.to_f;
        y = dragged.style.top.to_f;
     
        grip.dragEnd(grip, x, y);
     
        grip.ownerDocument.onmousemove = nil;
        grip.ownerDocument.onmouseup = nil
      end
    end
  end
end
