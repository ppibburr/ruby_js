module Uki2
  class Size < Array
    def initialize *o
      super()
      push *o
    end
    
    def width
      self[0]
    end
    
    def height
      self[1]
    end
  end
  
  class Point < Array
    def initialize *o
      super()
      push *o
    end  
    
    def x
      self[0]
    end
    
    def y
      self[1]
    end
  end

  module Rect
    attr_reader :position,:size
    def set_size size_or_w,h=nil
      if size_or_w.is_a?(Size)
        @size = size_or_w
      else
        h = size_or_w if !h
        @size=Size.new(size_or_w,h)
      end
    end
    
    def set_position pos_or_x,y=nil
      if pos_or_x.is_a?(Point)
        @position = pos_or_x
      else
        y = pos_or_x if !y
        @position = Point.new(pos_or_x,y) 
      end
    end
    
    def get_rect
      [].push(*size[0..1]).push(*position[0..1])
    end
  end

  class Object
    attr_reader :element,:parent
    def initialize parent,tag
      if parent.respond_to?('parent?')
        @parent = parent.parent?
      else 
        @parent = parent
      end
      
      def parent.element
        self
      end if !parent.is_a?(Uki2::Object)
      
      @element = parent.ownerDocument.createElement(tag)
      @parent.element.appendChild(@element)
    end
    
    def style
      element.style
    end
    
    def ownerDocument
      element.ownerDocument
    end
    
    def parent?
      self
    end
  end

  class Drawable < Object
    include Rect
    def initialize parent,*opts
      opts << {} if opts.empty?
      raise unless (opts=opts[0]).is_a?(Hash)
      opts[:tag] ||= 'div'
      super(parent,opts[:tag])    
      
      opts[:size] ||= Size.new(-1,-1)
      opts[:position] ||= Point.new(0,0)
      [:size,:position].each do |k|
        opts[k] = [opts[k]] unless opts[k].is_a?(Array)
        send("set_#{k}",*opts[k])
      end
      
      element.className = (element.className + " drawable").strip
    end
    
    def show
      element.style.left = (position.x).to_s+"px"
      element.style.top = ( position.y).to_s+"px"
      if size.width == -1 
        element.style.width = (parent.element.clientWidth.to_f-1).to_s+"px"
      else
        element.style.width = size.width.to_s+"px"
      end
      
      if size.height == -1 
        element.style.height = (parent.element.clientHeight.to_f-1).to_s+"px"      
      else
        element.style.height = size.height.to_s+"px"
      end
      
      element.className = (element.className.gsub("hidden",'') + " shown").strip
    end
  end

  class Container < Drawable
    attr_reader :children
    def initialize *o
      @children = []
      super *o
      element.className = (element.className + " container").strip      
    end
    
    def add q
      @children << q
    end
    
    def show q=true
      super()
      children.each do |c|
        c.show
      end if q
    end     
  end

  class Bin < Container
    def child
      children[0]
    end

    def add q
      return if children.length >= 1
      super q
    end
  end

  class Panel < Bin
    attr_reader :handle
    def initialize *o
      super
      element.className = (element.className + " panel").strip
      add c=@root=Container.new(self,:size=>[-1,-1])
      c.add @l=Uki2::Label.new(c,'Example ...',:size=>[-1,18])
      @l.element.className = (@l.element.className + " panel_handle").strip     
      @inner=Uki2::Bin.new(self,:size=>[-1,-1],:position=>[0,21]) 
      c.add @inner     
      def self.add q
        @inner.add q
      end    
    
      def self.child
        @inner.child
      end
    
      def self.children
        @inner.children
      end 
      
      @handle = @l
    end
    
    def parent?
      @inner || self
    end
    
    alias :show! :show
    def show  
      show!(nil)

      @root.show
      @handle.style.width = (@handle.parent.element.clientWidth.to_f-3).to_s+"px"
    end
  end
  
  class Window < Panel
    def initialize *o
      super
      element.className = (element.className + " window").strip
    end
  end

  class Scrollable < Bin
  end
  
  class Rule < Drawable
    def initialize *o
      super
      element.className = (element.className + " rule").strip
    end  
  end
  
  class HRule < Rule
    def initialize *o
      super
      size[1] = 5
    end
    
    def show()
      size[0] = -1
      super()
    end  
  end
 
  class Label < Drawable
    def initialize par,q,*o
      text = q
      if q.is_a? Hash
        o = [q]    
        text=nil    
      end
      
      super par,*o
  
      element.innerText = text.to_s     
 
      element.className = (element.className + " label").strip
    end    
  end 
  
  class Entry < Drawable
    def initialize par,q,*o
      text = q
      if q.is_a? Hash
        o = [q]    
        text=nil    
      end
      
      super par,*o
  
      element.innerText = text.to_s     
      size[1] = 20
      element.className = (element.className + " entry").strip
      element.contentEditable = true;
    end    
  end
  
  class TextView < Entry
    def initialize *o
      super
      size[1] = 100
      element.className = (element.className + " textview scrollable").strip
      element.contentEditable = true;
    end   
  end  
end
