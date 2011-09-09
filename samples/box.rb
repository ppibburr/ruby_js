module Rwt
  class Object
    attr_reader :resizable
  end
  class Box < Drawable
    CSS_CLASS = "box"
    attr_reader :children
    def initialize *o
      super
      Collection.new(self,[self]).add_class Box::CSS_CLASS 
      @resizable = true
      @children = []
    end
    
    def resize_to x,y
      set_size(Size.new.push(x,y))
      p children[0].class
      show
    end
    
    def add e,major=0,minor=0
    p [e.class,:hhhhhhhh]
      e.style['-webkit-box-flex']=major
      e.layout = FlexLayout.new(e,major,minor)     
      e.collection!.add_class("box_child")
      e.collection!.remove_class("fixed_child")      
      @children << e
    end
    
    def show
      super
      @children.each do |c|
        c.show
        c.layout.layout
      end
    end
  end
  
  class HBox < Box
    CSS_CLASS = "hbox"
    attr_reader :major_axis
    def initialize *o
      super
      @major_axis = Rwt::FlexLayout::X_MAJOR
      Collection.new(self,[self]).add_class HBox::CSS_CLASS
    end
  end
  
  class VBox < Box
    CSS_CLASS = "vbox"
    attr_reader :major_axis
    def initialize *o
      @major_axis = Rwt::FlexLayout::Y_MAJOR    
      super
      Collection.new(self,[self]).add_class VBox::CSS_CLASS      
    end
  end
end
