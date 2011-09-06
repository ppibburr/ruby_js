module Rwt
  class Box < Drawable
    CSS_CLASS = "box"
    attr_reader :children
    def initialize *o
      super
      Collection.new(self,[self]).add_class CSS_CLASS      
      @children = []
    end
    
    def add e,w=0,min=nil,max=nil
      e.style['-webkit-box-flex']=w
      e.style['max-width'] = max if max
      e.style['min-width'] = min if min      
      e.style.position = "static"
   #   e.set_size(Size.new.push(*[0,0]))
      @children << e
    end
    
    def show
      super
      @children.each do |c|
        c.show
      end
    end
  end
  
  class HBox < Box
    CSS_CLASS = "hbox"
    def initialize *o
      super
      Collection.new(self,[self]).add_class CSS_CLASS
    end
  end
  
  class VBox < Box
    CSS_CLASS = "vbox"

    def initialize *o
      super
      Collection.new(self,[self]).add_class CSS_CLASS      
    end
  end
end
