require 'rwt_ui'
if __FILE__ == $0
  require 'rubygems'
  require 'ijs'
  require 'rwt_ui'
end

module Rwt
  class Size
    attr_reader :width,:height
    def initialize a
      raise if !a.is_a?(Array)
      @width,@height = a
    end
  end

  class Point
    attr_reader :x,:y
    def initialize a
      raise if !a.is_a?(Array)
      @x,@y = a
    end
    alias :left :x
    alias :top :y
  end

  class Object
    attr_reader :shown,:element,:parent
    def initialize *o
      opts = {}
      parent = nil
      opts = o.last if o.last.is_a?(Hash)
      
      if o[0].is_a?(JS::Object) || o[0].is_a?(Rwt::Object)
        opts[:tag] ||= 'div'
        parent = o[0]
      elsif opts[:from]
        @element = opts[:from]
        @element.extend(UI::Object) if !@element.is_a?(UI::Object)
        @parent = @element.parentNode
        return
      else
        raise "unsupported construct"
      end
      
      @parent = parent
      if parent.is_a? JS::Object
        def parent.element
          self
        end
      elsif !parent.is_a?(Rwt::Object)
        raise "parent must be JS::Object or Rwt::Object"
      end
      
      @element = parent.ownerDocument.createElement(opts[:tag])
      @element.extend(UI::Object)
      @_display = to_collection.get_style('display')[0]
      
      @collection = to_collection
      
      parent.appendChild(@element)
    end
    
    def collection
      @collection
    end
    
    def method_missing *o,&b
      element.send(*o,&b)
    rescue
      super
    end
    
    def show
      @shown = true
      style.display = @_display
    end
    
    def hide
      @shown = false
      style.display = 'none'
    end
  end

  class STYLE;end
  STYLE::TAKE_WIDTH = 1
  STYLE::TAKE_HEIGHT = 2
  STYLE::TAKE_ALL = 3
  STYLE::CENTER=4
  STYLE::RELATIVE=8
  STYLE::ABSOLUTE=16
  STYLE::FIXED=32
  STYLE::DEFAULT = 64
  class Drawable < Object
    class Layout
      attr_reader :object
      attr_accessor :trim_w,:trim_h
      def initialize obj
        @object = obj
      end
      
      def take_all_width trim=0
        object.set_size(Size.new([UI::Collection.new(nil,[object.parent]).get_style('width').to_f,object.get_size.height+trim]))
      end
      
      def take_all_height trim=0
        object.set_size(Size.new([object.get_size.width,UI::Collection.new(nil,[object.parent]).get_style('height').to_f+trim])   )     
      end
      
      def take_all trim_w=0,trim_h=0
        object.set_size(Size.new([UI::Collection.new(nil,[object.parent]).get_style('width')[0].to_f+trim_w,
          UI::Collection.new(nil,[object.parent]).get_style('height')[0].to_f+trim_h])  )
      end
      
      def center
        if (object._style&STYLE::RELATIVE) == STYLE::RELATIVE
          ox = object.offsetLeft
          oy = object.offsetTop
          
          x = object.parent.clientWidth/2
          y = object.parent.clientHeight/2
          
          ox = ox+(x-ox)
          oy = oy+(y-oy)
          
          sub_x=object.clientWidth/2
          sub_y=object.clientHeight/2
          
          y = oy-sub_y
          x = ox-sub_x
          
          object.style.top = (y).to_s+"px"
          object.style.left = (x).to_s+"px"
        elsif object._style&STYLE::FIXED == STYLE::FIXED
          x = object.context.get_global_object.window.clientWidth
          y = object.context.get_global_object.window.clientHeight
          
          sub_y = object.collection.get_style('height')[0].to_f/2
          sub_x = object.collection.get_style('width')[0].to_f/2
          
          object.style.top = ((y/2.0)-sub_y).to_s+"px"
          object.style.left = ((x/2.0)-sub_x).to_s+"px"
        elsif object._style&STYLE::ABSOLUTE == STYLE::ABSOLUTE
          x = object.parent.offsetLeft
          y = object.parent.offsetTop
          puts "::::::::::::"
          p x
          x = x+object.parent.clientWidth
          y = y+object.parent.clientHeight
          p x
          sub_y = object.collection.get_style('height')[0].to_f/2
          sub_x = object.collection.get_style('width')[0].to_f/2
          p sub_x,:u88888888888
          object.style.top = ((y-sub_y)/2.0).to_s+"px"
          object.style.left = ((x-sub_x)/2.0).to_s+"px"        
        else
          raise "Unsupported Style"
        end
      end
      
      def update
        p @object._style
        if object._style&STYLE::TAKE_ALL ==STYLE::TAKE_ALL
          take_all @trim_w,@trim_h
        end
        
        if object._style&STYLE::CENTER == STYLE::CENTER
          center
        end
      end
    end
    
    # parent,size,position,style,opts={}
    attr_accessor :_style
    def initialize *o
      opts={}
      long = [:parent,:size,:position,:style]
      
      if o.last.is_a?(Hash)
        opts = o.last
        o.delete_at(o.length-1)
      end
      
      opts[:style]   ||= STYLE::RELATIVE
      opts[:size]    ||= [-1,-1]
      opts[:postion] ||= [0,0]
      
      if o[0]
        super(o[0],opts)
      else
        super(opts)
      end
      
      style.position = 'relative'
      
      if flags=opts[:style]
        set_style flags
      end
      
      o.delete_at(0)
      
      o.each_with_index do |a,i|
        case i
        when 0
          set_size(a)
        when 1
          set_position(a)
        when 2
          set_style(a);p :eeek
        else
          raise "Too many arguments"
        end
      end
      
      long[1..long.length-1].each do |k|
        if opts[k] and k!=:style
          send("set_#{k}",opts[k])
        end
      end
    end
    
    def set_size *o
      if o.length == 1
        if o[0].is_a?(Rwt::Size)
          size = o[0]
        elsif o[0].is_a?(Array)
          size = Rwt::Size.new(o[0])
        else
          raise ArgumentError.new("Expects 1 argument of Rwt::Size or Array, or 2 arguments of Integer")
        end
      elsif o.length == 2
        size = Rwt::Size.new(o)
      else
        raise "Too many arguments"
      end
      @_style||=0
      if size.width < 0 #and size.height >= 0
        @_layout||=Layout.new(self)
        @_layout.trim_w = size.width 
        set_style @_style|1 
      end
  
      if size.height < 0 #and size.width >= 0
        @_layout||=Layout.new(self)
        @_layout.trim_h = size.height 
        set_style @_style|2
      end  
      
      p @_style
      
      [:width,:height].each do |q|
        style.send("#{q}=", size.send(q).to_s+"px")
      end
    end
    
    def get_size
      w = collection.get_style('width').to_f
      h = collection.get_style('height').to_f
      Rwt::Size.new([w,h])
    end
    alias :size :get_size
    
    def set_position *o
      if o.length == 1
        if o[0].is_a?(Rwt::Point)
          point = o[0]
        elsif o[0].is_a?(Array)
          point = Rwt::Point.new(o[0])
        else
          raise ArgumentError.new("Expects 1 argument of Rwt::Point or Array, or 2 arguments of Integer")
        end
      elsif o.length == 2
        point = Rwt::Point.new(o)
      else
        raise "Too many arguments"
      end
      
      [[:left,:x],[:top,:y]].each do |q|
        style.send("#{q[0]}=", point.send(q[1]).to_s+"px")
      end    
    end
    
    def get_position
      x = collection.get_style('left').to_f
      y = collection.get_style('top').to_f
      Rwt::Point.new([x,y])    
    end
    
    def get_rect
      [get_position.x,get_position.y,get_size.width,get_size.height]
    end
    
    def set_style flags=0
      @_style ||= 0
      @_style = @_style|flags
      
      if flags&STYLE::RELATIVE == STYLE::RELATIVE
        style.position = 'relative'
      elsif flags&STYLE::ABSOLUTE == STYLE::ABSOLUTE
        style.position = 'absolute'      
      elsif flags&STYLE::FIXED == STYLE::FIXED
        style.position = 'fixed'      
      end
    end
    
    def get_css_style prop
      collection.get_style prop
    end
    
    def onsized
      draw
    end
    
    def draw
      @_layout||=Layout.new(self)
      @_layout.update
    end 
    
    def show
      super
      draw
      p @_style
    end
  end
  
  class Container < Drawable
    attr_reader :children
    def initialize *o
      super
      
      @children = []
    end
    
    def add child
      @children << child
    end
    
    def show
      super
      @children.each do |c| c.show end
    end
    
    def hide
      super
      @children.each do |c| c.hide end
    end
  end
end

STYLE = Rwt::STYLE

if __FILE__ == $0
  root = UI::Collection.new(document)
  document.body.innerHTML="<div id=test style='width:500px;height:500px;'></div>"
  o=Rwt::Container.new(root.find(:test)[0],:size=>[100,100],:style=>STYLE::CENTER|STYLE::RELATIVE)
  o.hide
  p o.collection.get_style('display')
  o.show
  p o.get_css_style('left')  
end
