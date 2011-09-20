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
        make_draggable
      end
    end  
  
    # make the object draggable
    def self.extended q
      q.set_style q.instance_variable_get("@_style")|STYLE::DRAGGABLE      
    end
    
    attr_reader :dnd_handler
    
    # makes the object draggable
    def make_draggable
      return if is_draggable?
      set_style @_style|STYLE::DRAGGABLE  if @_style&STYLE::DRAGGABLE != STYLE::DRAGGABLE    
      Rwt::UI::DragHandler.attach self
      @_is_draggable=true
      @dnd_handler=Rwt::UI::DragHandler.of(self)
    end
    
    def set_dragged q
      q = q.element if q.is_a?(Rwt::Object)
      dnd_handler.dragged = q
    end
    
    def set_grip q
      q = q.element if q.is_a?(Rwt::Object)
      dnd_handler.grip = q    
      @_is_draggable=true
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
  Examples=[
    "Extending Rwt::Drawable to make a draggable object",
    "Extending Rwt::Drawables to implement a object with a drag handle",
    "Implementing a Class of a draggable object",
    "Implementing a Class of an draggable object with a drag grip controlling the drag"
  ]
  
  def base document,idx
    root = Rwt::UI::Collection.new(document)
    document.body.innerHTML="<ul id=menu></ul><div id=test style=\"width:300px;height:300px;\"></div>" 
    menu = root.find(:menu).set_style('font-size','11px')[0]
    Examples.each_with_index do |e,i|
      o=Rwt::Drawable.new(menu,:size=>[1,20],:tag=>'li')
      o.style.width='400px'
      o.style.cursor='pointer'
      o.style.color='blue' unless idx==i+1
      o.set_style STYLE::BORDER if idx==i+1
      o.innerText = e
      o.show
      o.collection.on('click') do
        send "example#{i+1}",document
      end
    end
    
    return root
  end

  # example of extending Rwt::Drawable to make a draggable object
  def example1 document
    root = base(document,1)

    r = Rwt::Drawable.new(root.find(:test)[0],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::FLAT)
    r.extend Rwt::Draggable    
    r.innerText = "Drag me..."
    r.show
  end

  # Example of extending Rwt::Drawables to implement a object with a drag handle
  def example2 document
    root = base(document,2)

    r = Rwt::VBox.new(root.find(:test)[0],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::FLAT)
    r.add h = Rwt::Drawable.new(r,:size=>[1,20],:style=>STYLE::BORDER_ROUND_TOP),0,true
    r.add c = Rwt::Drawable.new(r,:size=>[1,1]),1,true  

    h.extend Rwt::Draggable
    h.set_dragged r

    h.innerText="Drag here ..."

    r.show
  end  
 
  # Example of implementing a class of a draggable object
  class ImplementsDrag < Rwt::Drawable
    include Rwt::Draggable
  end

  # ImplementsDrag example
  def example3 document
    root = base(document,3)

    r = ImplementsDrag.new(root.find(:test)[0],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::FLAT|STYLE::DRAGGABLE)
    r.innerText = "Drag me..."
    r.show
  end

  # Example of implementing a class of an object with a drag grip
  class DragPanel < Rwt::VBox
    include Rwt::Draggable
    # By default we will not be draggable
    # unless _Style matches the STYLE::DRAGGED mask
    # or make_draggable is called
    def initialize *o
      super
      add @handle = Rwt::Drawable.new(self,:style=>STYLE::BORDER_ROUND_TOP|STYLE::RAISED,:size=>[1,20]),0,1
      @handle.innerText = "Drag here ..."
      add content = Rwt::VBox.new(self,:style=>STYLE::FLAT|STYLE::BORDER_ROUND_BOTTOM),1,1
      
      set_grip @handle
    end
  end

  # DragPanel example
  def example4 document
    root = base(document,4)

    r = DragPanel.new(root.find(:test)[0],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::DRAGGABLE) 
    r.show     
  end

  w = Gtk::Window.new 0
  v = WebKit::WebView.new
  w.add v
  v.load_html_string "<html><body style='width:800px;height:600px;'></body></html>",nil

  v.signal_connect('load-finished') do |o,f|
   example1 f.get_global_context.get_global_object.document
  end

  w.signal_connect("delete-event") do
   Gtk.main_quit
  end

  w.set_size_request 800,600

  w.show_all

  Gtk.main
end

