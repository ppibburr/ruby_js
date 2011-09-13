module Rwt
  module Resizer
    def initialize *o
      super
      collection!.add_class("listen_resize")
    end
  end
  
  class Handle < HBox
    CSS_CLASS = "panel_handle"
    def initialize par,text='',*o
      if !text.is_a?(String)
        o=text
        if !o.is_a?(Array)
          o=[0]
        end
      end
      super par,*o
      collection!.add_class(CSS_CLASS)    
      add @label = Rwt::Label.new(self,text),1
      add @shade = Rwt::Container.new(self,:size=>[50,-1])
      @shade.element.innerText = "[-]"
      collection!.bind(:click) do
        parent.element.ontoggle()
      end
      
      def toggle
        if parent.shaded
          @shade.element.innerText = "[+]" 
        else
          @shade.element.innerText = "[-]"          
        end
      end
    end
  end
  
  class Panel < VBox
    include Resizer
    CSS_CLASS = "panel"
    attr_reader :shaded,:inner
    def initialize par,text='',*o
      if !text.is_a?(String)
        o=text
        if !o.is_a?(Array)
          o=[0]
        end
      end
      super par,*o
      add! @handle=Handle.new(self,text),0,1
      add!((i=Bin.new(self,:size=>[-10,-25],:position=>[5,0])),0,0)
      @inner=i
      collection!.add_class(CSS_CLASS)
      collection!.add_class("toplevel")
      collection!.remove_class "fixed_child"
      
      collection!.bind(:resize) do |this,cw,ch|
        on_resize this,cw,ch   
      end
      
      collection!.bind(:toggle) do
        toggle
      end
      
      @resizable = true
    end
    
    def on_resize t,w,h
      size[0] = element.clientWidth.to_f
      size[1] = element.clientHeight.to_f
      @inner.style.width = (@inner.size[0]=size[0]-10).to_s+"px"
      @inner.style.height = (@inner.size[1]=size[1]-25).to_s+"px"
      if @inner.child.resizable
        e=@inner.child
        e.resize_to *@inner.size.map do |d| d-1 end
      end     
    end
    
    def resize_to x,y
    p x,y,:hhhh
      set_size(Size.new().push(x,y))
      show
    end
    
    def toggle
      if !shaded
        @_pre_shade_height = element.clientHeight
        size[1] = 20
        @shaded = true
        element.style.maxHeight = size[1].to_s+"px"
        element.style.height = size[1].to_s+"px"
      else
        size[1]=@_pre_shade_height
        element.style.height=  size[1].to_s+"px"
        element.style.maxHeight = "100%"        
        @shaded = false
      end
      @handle.toggle
    end
    
    alias :'add!' :add
    
    def parent?
      @inner || self
    end
    
    def show
      super

    end

    
    def add *o
      @inner.add *o
      o[0].style.position='relative'      
    end
  end
end
