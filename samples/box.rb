module Rwt
  class Box < Drawable
    CSS_CLASS = "box"
    attr_reader :children
    def initialize *o
      super
      Collection.new(self,[self]).add_class CSS_CLASS      
      @children = []
    end
    
    def add e,w=0
      e.style['-webkit-box-flex']=w     
      e.style.position = "static"
      @children << e
    end
    
    def show
      super
      @children.each do |c|
        c.show
        c.style.height='auto'
        c.style.width='auto'
      end
    end
  end
  
  class HBox < Box
    CSS_CLASS = "hbox"
    def initialize *o
      super
      Collection.new(self,[self]).add_class CSS_CLASS
    end
    
    def add e,w=0,min=nil,max=nil
      super e,w
      e.style['max-width'] = max if max
      e.style['min-width'] = min if min       
    end
  end
  
  class VBox < Box
    CSS_CLASS = "vbox"

    def initialize *o
      super
      Collection.new(self,[self]).add_class CSS_CLASS      
    end
    
    def add e,w=0,min=nil,max=nil
      super e,w
      e.style['max-height'] = max if max
      e.style['min-height'] = min if min       
    end    
  end
end
