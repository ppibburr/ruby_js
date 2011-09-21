if __FILE__ == $0
  p Dir.getwd
  $: << Dir.getwd
  require 'rwt2'
end

module Rwt
  STYLE::DRAGGABLE = STYLE::RESIZABLE*2
  # Convience for Rwt::Drawable's to become draggable
  # via extending by objects or including in class
  # by default objects of classes including this module
  #   must have _style set to match the STYLE::DRAGGABLE mask
  #   or have the method make_draggable provided from this module called
  module Draggable
    # passing an ORedthat has the SYLE::DRAGGABLE mask makes the object draggable
    def set_style flags=0
      super
      if flags&STYLE::DRAGGABLE == STYLE::DRAGGABLE
        make_draggable self,self
      end
    end  
  
    # make the object draggable
    def self.extended q
      q.set_style q.instance_variable_get("@_style")|STYLE::DRAGGABLE      
    end
    
    attr_reader :drag_handler
    
    # makes the object draggable
    def make_draggable(grip=self,dragged=self)
      return if is_draggable?
      set_style @_style|STYLE::DRAGGABLE  if @_style&STYLE::DRAGGABLE != STYLE::DRAGGABLE    
      Rwt::UI::DragHandler.attach @_drag_grip=grip,@_dragged=dragged
      @_is_draggable=true
      @drag_handler=Rwt::UI::DragHandler.of(grip)
    end
    
    def no_drag!
      @_is_draggable=false
      self.onmousedown = :undefined
      style.cursor='auto'
    end
    
    def is_draggable?
      @_is_draggable
    end
  end
end

if __FILE__ == $0
  require 'demo_common'

  STYLE = Rwt::STYLE

  Examples=[
    "Extending Rwt::Drawable to make a draggable object",
    "Extending Rwt::Drawables to implement a object with a drag handle",
    "Implementing a Class of a draggable object",
    "Implementing a Class of an draggable object with a drag grip controlling the drag"
  ]

  # example of extending Rwt::Drawable to make a draggable object
  def example1 document
    root,window = base(document,1)

    r = Rwt::Drawable.new(root.find(:test)[0],:size=>[250,200],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::FLAT)
    r.extend Rwt::Draggable    
    r.innerText = "Drag me..."
    r.show
  end

  # Example of extending Rwt::Drawables to implement a object with a drag handle
  def example2 document
    root,window = base(document,2)

    r = Rwt::VBox.new(root.find(:test)[0],:size=>[250,200],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::FLAT)
    r.add h = Rwt::Drawable.new(r,:size=>[1,20],:style=>STYLE::BORDER_ROUND_TOP),0,true
    r.add c = Rwt::Drawable.new(r,:size=>[1,1]),1,true  

    h.extend Rwt::Draggable
    h.dragged=r.element
    h.innerText="Drag here ..."

    r.show
  end  
 
  # Example of implementing a class of a draggable object
  class ImplementsDrag < Rwt::Drawable
    include Rwt::Draggable
  end

  # ImplementsDrag example
  def example3 document
    root,window = base(document,3)

    r = ImplementsDrag.new(root.find(:test)[0],:size=>[250,200],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::FLAT|STYLE::DRAGGABLE)
    r.innerText = "Drag me..."
    r.show
  end

  # Example of implementing a class of an object with a drag grip
  class DragPanel < Rwt::VBox
    include Rwt::Draggable
    
    # Prevent super of initialize setting default of grip=self,dragged=self from set_style call
    # @_style_has_draggable will que initialize to goat head and become draggable
    def make_draggable grip,dragged
      @_style_has_draggable = true
      return if !@_init
      super
    end
    
    # By default we will not be draggable
    # unless _Style matches the STYLE::DRAGGED mask
    # or make_draggable is called
    def initialize *o
      super
      add @handle = Rwt::Drawable.new(self,:style=>STYLE::BORDER_ROUND_TOP|STYLE::RAISED,:size=>[1,20]),0,1
      @handle.style.cursor = 'move'
      @handle.innerText = "Drag here ..."
      add content = Rwt::VBox.new(self,:style=>STYLE::FLAT|STYLE::BORDER_ROUND_BOTTOM),1,1
      
      @_init = true
      
      if @_style_has_draggable
        make_draggable @handle,self
      end
    end
  end

  # DragPanel example
  def example4 document
    root,window = base(document,4)

    r = DragPanel.new(root.find(:test)[0],:size=>[250,200],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::DRAGGABLE) 
    r.show     
  end

  launch
end

