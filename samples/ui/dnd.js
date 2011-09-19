var DragHandler = {
  _temp: [],
  // public method. Attach drag handler to an element.
  initialize: function(grip,drag) {
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
    self = DragHandler;
    w=self.grip;

    w.hint.collection()[0].style.top = self.dragged.style.top;
    w.hint.collection()[0].style.left = self.dragged.style.left;
    w.hint.collection()[0].style.height = self.dragged.style.height;
    w.hint.collection()[0].style.width=self.dragged.style.width;
    w.hint.element().style.display='block';
    self.dragged=w.hint.element()
    self=DragHandler;;
    x  = parseInt(self.dragged.style.left);
    y  = parseInt(self.dragged.style.top);
    
    self._temp = [x,y];

    self.grip['dragBegin'] && !self.grip.dragBegin(self.grip, x, y) ? false : null;      
 
    e = e ? e : window.event;
    self.dragged.mouseX = e.clientX;
    self.dragged.mouseY = e.clientY;
 
    document.onmousemove = self.drag;
    document.onmouseup = self.dragEnd;
    return false;
  },
 
 
  //# private method. Drag (move) element.
  drag: function(q,e) { 
        self=DragHandler;;
            e = e ? e : window.event;
    x=self._temp[0];
    y=self._temp[1]
    dx = e.clientX - self.dragged.mouseX;
    dy = e.clientY - self.dragged.mouseY;
    nx = x + (dx) ;
    ny = y + (dy);
    self.dragged.mouseX = e.clientX;
    self.dragged.mouseY = e.clientY;
    self.grip['drag'].call(self.grip, nx,ny,dx, dy) ? null : false; 
    self._temp=[nx,ny];

    //self.dragged.style.left = (nx)+ 'px';
    //self.dragged.style.top = (ny)+ 'px';
    self.dragged.style.width = (parseInt(self.dragged.style.width)+dx)+"px"
    return false;
  },
 
 
  //# private method. Stop drag process.
  dragEnd: function() {
    DragHandler.grip.dragEnd(DragHandler.grip, DragHandler._temp[0],DragHandler._temp[1]);
    DragHandler.dragged.style.width = DragHandler._temp[0]+"px";
    DragHandler.dragged.style.display='none';
    DragHandler.grip = DragHandler.dragged;
    document.onmousemove = null;
    document.onmouseup = null;
  }
}
DragHandler;
