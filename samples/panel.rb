module Rwt
  module Resizer
    def initialize *o
      super
      collection!.add_class("listen_resize")
    end
  end
  
  class Handle < HBox
    CSS_CLASS = "panel_handle"
    def initialize *o
      super
      collection!.add_class(CSS_CLASS)
      add @label = Rwt::Label.new(self,"Resizable Panel Example"),1
      add @shade = Rwt::Container.new(self,:size=>[50,-1])
      @shade.element.innerText = "[-]"
      collection!.bind(:click) do
        parent.toggle
      end
    end
  end
  
  class Dow < VBox
    include Resizer
    CSS_CLASS = "panel"
    attr_reader :shaded,:inner
    def initialize *o
      super
      add! @handle=Handle.new(self),1,'20px','20px'
      add!((i=Bin.new(self)),1)
      @inner=i
      collection!.add_class(CSS_CLASS)
      collection!.add_class("toplevel")
      collection!.remove_class "fixed_child"
      collection!.bind(:resize) do |this,cw,ch|
        size[0] = size[0]-cw
        size[1] = size[1]-ch
      end
    end
    
    def toggle
      if !shaded
        @_pre_shade_height = element.clientHeight
        size[1] = 20
        @shaded = true
        @inner.hide
        element.style.height = size[1].to_s+"px"
      else
        size[1]=@_pre_shade_height
        element.style.height=  size[1].to_s+"px"
        @inner.show
        @shaded = false
      end
    end
    
    alias :'add!' :add
    
    def parent?
      @inner || self
    end
    
    def add *o
      @inner.add *o
      o[0].style.position='relative'      
    end
  end
end
