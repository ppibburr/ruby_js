module Rwt
  class Collection < Array  
    def initialize from,*o
      @from = from
      super(*o)
    end
    
    def [] *o
      find *o
    end
    
    def bind *o,&b
    
    end
    
    def add_class n
      each do |o|
        o.className = (o.className + " #{n}").strip     
      end
    end
    
    def remove_class n
      each do |o|    
        o.className = o.className.gsub(Regexp.new("^#{o}$"),'')
        o.className = o.className.gsub(Regexp.new(" #{o}$"),'')
        o.className = o.className.gsub(Regexp.new("^#{o} "),'')
        o.className = o.className.gsub(Regexp.new(" #{o} "),' ')   
        o.className = o.className.strip     
      end     
    end
    
    def style k,v
    
    end
    
    def find_id(q)
     if @from.is_a?(Collection)
       @from.find! do |o| o.id == q.to_s end  
     elsif @from.is_a?(JS::Object)
       @from.get_element_by_id(q.to_s)
     elsif @from.is_a?(Rwt::Object)
       @from.element.get_element_by_id(q.to_s)
     end
    end
 
    def find_class(q)
     r=nil
     if @from.is_a?(Collection)
       r=@from.find_all do |o| o.className.split(" ").index(q) end  
     elsif @from.is_a?(JS::Object)
       r=@from.get_elements_by_class_name(q)
     elsif @from.is_a?(Rwt::Object)
       r=@from.element.get_elements_by_class_name(q)
     end
     
     if r
       if r.is_a?(Array)
         r
       elsif r.is_a?(JS::Object)
         a = []
         for i in 0..r.length-1
           a << r[i]
         end
         a
       end  
     end
    end 
    
    alias :'find!' :find
    
    def find *o
      c = []
      
      o.each do |q|
        if q.is_a?(Symbol)
          c << find_id(q)
        elsif q.is_a?(String)
          if q =~ /^\.(.*)/
            c.push *find_class($1)
          elsif q=~/^\#(.*)/
            c << find_id($1)
          else
            c.push(*find_name(q))
          end
        end
      end
      c = Collection.new(self,c.uniq)
    end    
  end
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
      [].push(*position[0..1]).push(*size[0..1])
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
      end if !parent.is_a?(Rwt::Object)
      
      return if !tag
      @element = parent.ownerDocument.createElement(tag)
      @parent.element.appendChild(@element)
    end
    
    def id
      element.id
    end
    
    def id= idnt
      element.id = idnt
    end
    
    def className
      element.className
    end
    
    def className= s
      element.className = s
    end
    
    def name
      element.name
    end
    
    def name= n
      element.name = n
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

      if size.width <= -1 
        element.style.width = (size[0]=(parent.element.clientWidth.to_f+size.width)).to_s+"px"
      else
        element.style.width = size.width.to_s+"px"
      end
      
      if size.height <= -1 
        element.style.height = (size[1]=(parent.element.clientHeight.to_f+size.height)).to_s+"px"      
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
        yield c if block_given?
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
    def initialize par,q,*o
      title = q
      if q.is_a? Hash
        o = [q]    
        title=nil    
      end    
    
      super par,*o
      element.className = (element.className + " panel").strip
      add c=@root=Container.new(self,:size=>[-1,-1])
      c.add @l=Rwt::Label.new(c,title,:size=>[-1,18])
      @l.element.className = (@l.element.className + " panel_handle").strip     
      @inner=Rwt::Bin.new(self,:size=>[-1,-20],:position=>[0,21]) 

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
  
  class Foriegn < Drawable
    attr_accessor :object
    def initialize par,*o
      super par,*o
    end
    
    def show(q=nil);
      super() if q
    end
  end
  
  class Table < Foriegn
    def initialize par,*o
      super

      begin
        @uki = JS.execute_script(parent.element.context,"uki;")
      rescue
        JS::Script.load parent.element.context,"uki.dev.js"
        @uki = JS.execute_script(parent.element.context,"uki;")
      end

      @opts = o[0]
      @columns = @opts[:columns] ||= []
      @data = @opts[:data]
    end
    
    def add_column opts
      @columns << opts
    end
    
    def show
      super(true)
      return if @init
      @init = true
      @opts[:anchors] ||= DEF_OPTS[:anchors]
    
      @columns.each do |c|
        Column::DEF_OPTS.each_pair do |k,v|
          next if c[k]
          c[k] = v
        end
      end
      
      if position[1] == 0
        position[1] = 1
        size[1] = size[1] - 1
      end
      
      @object = @view = @uki.call({ 
        :view=>'Table', 
        :rect=>get_rect.join(" "),
        :anchors=>@opts[:anchors], 
        :columns => @columns,
        :multiselect => true, 
        :style => {:fontSize=>'11px', :lineHeight=>'11px'}
      })
      
      data(@data) if @data
      
      @view.attachTo(@parent.element)    
    end
    
    def data a=nil
      return @data=@view.data(a) if a and @view
      return @data = a if a 
      @data = @view.data
    end
    
    module Column
      CUSTOM = "table.CustomColumn"
      NUMBER = "table.NumberColumn" 
      DEF_OPTS = {
        :resizable=>true,
        :view=>Column::CUSTOM,
        :width=>100
      }  
    end
    
    DEF_OPTS = {
      :anchors => 'left top right bottom'
    } 
  end
end
