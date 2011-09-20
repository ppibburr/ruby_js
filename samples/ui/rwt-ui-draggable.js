var Rwt = new Object();
  
Rwt.ui = function() {};
Rwt.UI = {
  DragHandler: {
    _temp: [],
    // public method. Attach drag handler to an element.
    attach: function(grip,drag) {
      this.grip = grip;
      this.dragged = drag;

      grip.onmousedown = this.dragBegin;

      //# callbacks
      grip.dragBegin = function() { return true;};
      grip.drag = function() { return true;};
      grip.dragEnd = function() { return true;};
      
    },
   
   
    //# private method. Begin drag process.
    dragBegin: function(q,e) {
      self=Rwt.UI.DragHandler;;
      x  = parseInt(self.dragged.style.left);
      y  = parseInt(self.dragged.style.top);
      x = (x.toString()=="NaN") ? 0 : x;
      y = (y.toString()=="NaN") ? 0 : y;
      self._temp = [x,y];

      if (self.grip.dragBegin(self.grip, x, y) === false) {
        return false;
      }
   
      e = e ? e : window.event;
      self.dragged.mouseX = e.clientX;
      self.dragged.mouseY = e.clientY;
   
      document.onmousemove = self.drag;
      document.onmouseup = self.dragEnd;
      return false;
    },
   
   
    //# private method. Drag (move) element.
    drag: function(q,e) { 
      self=Rwt.UI.DragHandler;;

      e = e ? e : window.event;

      x=self._temp[0];
      y=self._temp[1];

      dx = e.clientX - self.dragged.mouseX;
      dy = e.clientY - self.dragged.mouseY;
      nx = x + (dx) ;
      ny = y + (dy);

      self.dragged.mouseX = e.clientX;
      self.dragged.mouseY = e.clientY;
      // 
      if (self.grip.drag(self.grip, nx,ny,dx, dy)  === false) {
        return false;
      }

      self._temp=[nx,ny];

      self.dragged.style.left = (nx)+ 'px';
      self.dragged.style.top = (ny)+ 'px';

      return false;
    },
   
   
    //# private method. Stop drag process.
    dragEnd: function() {
      self = Rwt.UI.DragHandler;
      if (self.grip.dragEnd(self.grip)  === false) {
        return false;
      }    
      document.onmousemove = null;
      document.onmouseup = null;
    }
  }
}

Rwt.UI.DragHandler;
