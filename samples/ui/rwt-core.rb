if __FILE__ == $0
  require 'rwt2'
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
      @x,@y=a
    end
    alias :left :x
    alias :top :y
    
    def self.from(el)
       _x = 0;
       _y = 0;
      while el && el['offsetLeft']!=:undefined && el['offsetTop']!=:undefined 
          _x += el.offsetLeft - el.scrollLeft;
          _y += el.offsetTop - el.scrollTop;
          # chrome/safari
          el = el.parentNode;
      end
      self.new [_x,_y];   
    end
    
    # returns a point where 0,0 
    # should be assumed to be 
    # pt.x,pt.y
    def translate pt
      rel_pt = pt
      rx,ry = rel_pt.x,rel_pt.y
      tx=rx-x
      ty=ry-y
      Point.new([tx,ty])
    end
    
    def self.center_of o
      ox,oy = from(o).x,from(o).y
      oc = UI::Collection.new(nil,[o])
      w,h = oc.get_style('width')[0].to_f,oc.get_style('height')[0].to_f
      p [:f,w,h]
      cx=ox+(w/2.0)
      cy=oy+(h/2.0)
      p [:d,cx,cy]
      self.new([cx,cy])
    end
    
    def center_object o
      ox,oy,w,h = o.get_rect
      tx=x-(w*0.5)
      ty=y-(h*0.5)
      p [:ctx,tx,ty]
      Point.new([tx,ty])
    end
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
      elsif opts[:from];p 9999
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
      @element.to_collection.set_style("margin","0px 0px 0px 0px")
      
      @_display = to_collection.get_style('display')[0]
      
      @collection = to_collection
      
      parent.appendChild(@element)
      
        style['min-width']='0px'
        style['min-height']='0px'      
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
      @_display = to_collection.get_style('display')[0] if @shown && to_collection.get_style('display')[0]!='none'
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
  STYLE::BORDER=64
  STYLE::BORDER_ROUND = 128
  STYLE::BORDER_ROUND_LEFT = 256
  STYLE::BORDER_ROUND_RIGHT = 512
  STYLE::BORDER_ROUND_TOP = 1024
  STYLE::BORDER_ROUND_BOTTOM = 2048
  STYLE::SHADOW = 4096
  STYLE::SHADOW_INSET = 8192
  STYLE::RAISED = STYLE::SHADOW|STYLE::BORDER
  STYLE::SUNKEN = STYLE::SHADOW_INSET|STYLE::BORDER
  STYLE::FLAT = STYLE::SHADOW_INSET*2|STYLE::BORDER|STYLE::SHADOW
  STYLE::BOTTOM = STYLE::SHADOW_INSET*2*2
  
  class Drawable < Object
    class Layout
      attr_reader :object
      attr_accessor :trim_w,:trim_h
      def initialize obj
        @object = obj
        @trim_w,@trim_h = 0,0
      end
      
      def take_all_width trim=0
        object.set_size(Size.new([UI::Collection.new(nil,[object.parent]).get_style('width')[0].to_f+trim,object.get_size.height]))
      end
      
      def take_all_height trim=0
        object.set_size(Size.new([object.get_size.width,UI::Collection.new(nil,[object.parent]).get_style('height')[0].to_f+trim])   )     
      end
      
      def take_all trim_w=0,trim_h=0
        object.set_size(Size.new([UI::Collection.new(nil,[object.parent]).get_style('width')[0].to_f+trim_w,
          UI::Collection.new(nil,[object.parent]).get_style('height')[0].to_f+trim_h])  )
      end
      
      def center  q = object.parent
          q = object.ownerDocument.body if object.has_style STYLE::FIXED # fixed position is based from window (FIXME: using body ...)

          # the absolute (from <html>) position of the parent
          ppt = Point.from(q)
          
          # get the center of parent
          cpt = Point.center_of(q)
          
          # get the position of the object centered on parents center
          pt = cpt.center_object(object)
          
          # thats it for fixed
          x,y = pt.x,pt.y
          
          # adjust for relative elements
          if object.has_style(STYLE::RELATIVE)
            # translate difference of parent point and point 
            tp = ppt.translate(pt)
            
            # set to the differnce
            x=tp.x
            y=tp.y
            
            opt = Point.from(object)
            
            o = ppt.translate(opt)

            x=x-(o.x)
            y=y-(o.y)    
          # for absolute elements  
          elsif object.has_style(STYLE::ABSOLUTE)
            # translate difference of parent point and point 
            tp = ppt.translate(pt)
            
            # set to the differnce
            x=tp.x
            y=tp.y
          end
          
          object.set_position [x,y]
      end
      
      def bottom_left
        Point.from(object.parent)
      end
      
      def update
        if object._style&STYLE::TAKE_ALL ==STYLE::TAKE_ALL
          take_all @trim_w,@trim_h
        end

        if object._style&STYLE::TAKE_ALL ==STYLE::TAKE_WIDTH
          take_all_width @trim_w
        end
        
        if object._style&STYLE::TAKE_ALL ==STYLE::TAKE_HEIGHT
          take_all_height @trim_h
        end        
        
        if object._style&STYLE::CENTER == STYLE::CENTER
          center
        end
        
        if object._style&STYLE::BOTTOM == STYLE::BOTTOM
          bottom
        end        
      end
    end
    
    class Border
      attr_reader :object
      def initialize object
        @object = object
        init
      end
      
      def init
        width 1
        color "#666"
        style "solid"
      end
      
      def color col
        object.style['border-color'] = col
      end
      
      def style sty
        object.style['border-style'] = sty
      end
      
      def width px
        object.style['border-width'] = "#{px}px"
      end
      
      def round px = 5
        top_radius px
        bottom_radius px
      end
      
      def bottom_radius px
        bottom_left_radius px
        bottom_right_radius px       
      end
      
      def top_radius px
        top_left_radius px
        top_right_radius px        
      end
      
      def left_radius px
        bottom_left_radius px
        top_left_radius px     
      end
      
      def right_radius px
        bottom_right_radius px
        top_right_radius px       
      end
      
      def bottom_left_radius px    
        object.style['border-bottom-left-radius'] = px.to_s+"px"
      end
     
      def top_left_radius px    
        object.style['border-top-left-radius'] = px.to_s+"px"
      end   

      def bottom_right_radius px    
        object.style['border-bottom-right-radius'] = px.to_s+"px"
      end   
      
      def top_right_radius px    
        object.style['border-top-right-radius'] = px.to_s+"px"
      end                                    
    end
    
    class Shadow
      attr_reader :object
      def initialize object
        @object=object
        init
      end
      
      def init
        y_offset 1
        x_offset 1
        blur 0
        spread 0
      end
      
      def inset
        @inset = "inset "
        set
      end
      
      def normal
        @inset = ''
        set
      end
      
      def y_offset px=nil
        px ||= @y_offset ||= 0 
        @y_offset=px        
        set
        @y_offset      
      end
 
      def x_offset px=nil
        px ||= @x_offset ||= 0 
        @x_offset=px      
        set
        @x_offset     
      end
      
      def spread px=nil
        px ||= @shadow ||= 0 
        @spread=px      
        set      
        @spread
      end
      
      def blur px=nil
        px ||= @blur ||= 0 
        @blur=px
        set
        @blur     
      end
      
      def color col=nil
        col ||= @color ||= '#666' 
        @color=col
        set
        @color     
      end   
      
      def set
        object.style['-webkit-box-shadow'] = "#{@inset}#{@x_offset||0}px #{@y_offset||0}px #{@blur||0}px #{@spread||0}px #{@color||'#666'}"      
      end   
    end
    
    # parent,size,position,style,opts={}
    attr_accessor :_style,:_border,:_shadow
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
      
      [:width,:height].each do |q|
        style.send("#{q}=", size.send(q).to_s+"px")
      end
    end
    
    def get_size
      w = get_css_style('width').to_f
      h = get_css_style('height').to_f
      Rwt::Size.new([w,h])
    end
    alias :size :get_size
    
    def grow_x amt
      w,h = get_size.width,get_size.height
      set_size w+amt,h    
    end
    
    def grow_y amt
      w,h = get_size.width,get_size.height
      set_size w,h+amt   
    end
    
    def grow x,y=nil
      y ||= x
      grow_x x
      grow_y y
    end
    
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
      Rwt::Point.from(self)  
    end
    
    def get_rect
      [get_position.x,get_position.y,get_size.width,get_size.height]
    end
    
    def get_css_position
      Point.from(parent).translate(get_position)
    end
    
    def get_css_rect
      [get_css_position.x,get_css_position.y,get_size.width,get_size.height]    
    end
    
    def set_style flags=0
      @_style ||= 0
      @_style = flags
      
      if flags&STYLE::RELATIVE == STYLE::RELATIVE
        style.position = 'relative'
      elsif flags&STYLE::ABSOLUTE == STYLE::ABSOLUTE
        style.position = 'absolute'      
      elsif flags&STYLE::FIXED == STYLE::FIXED
        style.position = 'fixed'      
      end

      if get_css_style("position") == "fixed"
        if @_style&STYLE::FIXED != STYLE::FIXED
          @_style = @_style|STYLE::FIXED
        end
      elsif get_css_style("position") == "relative"
        if @_style&STYLE::RELATIVE != STYLE::RELATIVE
          @_style = @_style|STYLE::RELATIVE
        end
      elsif get_css_style("position") == "absolute"
        if @_style&STYLE::ABSOLUTE != STYLE::ABSOLUTE
          @_style = @_style|STYLE::ABSOLUTE
        end
      end
      
      if flags&STYLE::BORDER == STYLE::BORDER
        @_border ||= Border.new(self)
      end
      if flags&STYLE::BORDER_ROUND == STYLE::BORDER_ROUND
        @_border ||= Border.new(self)
        @_border.round
        @_style=@_style|STYLE::BORDER if @_style&STYLE::BORDER != STYLE::BORDER
      end
      if flags&STYLE::BORDER_ROUND_LEFT == STYLE::BORDER_ROUND_LEFT
        @_border ||= Border.new(self)
        @_border.left_radius 3
        @_style=@_style|STYLE::BORDER if @_style&STYLE::BORDER != STYLE::BORDER
      end  
      if flags&STYLE::BORDER_ROUND_RIGHT == STYLE::BORDER_ROUND_RIGHT
        @_border ||= Border.new(self)
        @_border.right_radius 3
        @_style=@_style|STYLE::BORDER if @_style&STYLE::BORDER != STYLE::BORDER
      end 
      if flags&STYLE::BORDER_ROUND_TOP == STYLE::BORDER_ROUND_TOP
        @_border ||= Border.new(self)
        @_border.top_radius 3
        @_style=@_style|STYLE::BORDER if @_style&STYLE::BORDER != STYLE::BORDER
      end 
      if flags&STYLE::BORDER_ROUND_BOTTOM == STYLE::BORDER_ROUND_BOTTOM
        @_border ||= Border.new(self)
        @_border.bottom_radius 3
        @_style=@_style|STYLE::BORDER if @_style&STYLE::BORDER != STYLE::BORDER
      end    
      
      if flags&STYLE::SHADOW == STYLE::SHADOW
        @_shadow||=Shadow.new(self)
      end 
      if flags&STYLE::SHADOW_INSET == STYLE::SHADOW_INSET
        @_shadow||=Shadow.new(self)
        @_shadow.inset
        @_style=@_style|STYLE::SHADOW if @_style&STYLE::SHADOW != STYLE::SHADOW
      end   
      
      if @_style&STYLE::RAISED == STYLE::RAISED
        style['background-color']="#efefff"
      end
      if @_style&STYLE::SUNKEN == STYLE::SUNKEN
        style['background-color']="#ececec"
      end
      if @_style&STYLE::FLAT == STYLE::FLAT
        style['background-color']="#EEEEEE"
        _shadow.x_offset 0
        _shadow.y_offset 0
        _shadow.spread 0
        _shadow.blur 5  
      end                                      
    end
    
    def get_style
      @_style
    end
    
    def has_style flag
      @_style&flag == flag
    end
    
    def append_style flag
      set_style @_style|flag
    end
    
    def remove_style flag
      set_style @_style&~flag
    end
    
    def get_css_style prop
      collection.get_style(prop)[0]
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

if __FILE__ == $0
  require 'demo_common'
  
  STYLE=Rwt::STYLE

  Examples = [
    "First object centered to window FIXED",
    "First Object centered to parent RELATIVE",
    "First Object centered to parent ABSOLUTE"    
  ]

  alias :base_ :base
  
  def base d,i
    r,w=base_ d,i
    r.find(:test)[0].style.cssText="position:absolute;left:100px;top:100px;;width:600px;height:600px;background-color:#cecece" 
    return r,w
  end

 def example1 document
  root,window = base(document,1)
  
  r=Rwt::Container.new(root.find(:test)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::FIXED|STYLE::BORDER_ROUND_LEFT|STYLE::FLAT) 
  r.innerHTML="<p>Fixed elements are always relative to html 0,0</p>" 
  
  r.add o=Rwt::Container.new(r,:size=>[400,400],:style=>STYLE::CENTER|STYLE::ABSOLUTE|STYLE::RAISED)
  o.innerHTML="<p></p>"   
  
  o.add c1=Rwt::Button.new(o,'',:size=>[200,200],:style=>STYLE::RELATIVE|STYLE::CENTER|STYLE::SUNKEN)
    
  Rwt::UI::Collection.new(nil,[r,o,c1]).set_style('color','#666').on('mouseover') do
    ele=window.event.target
    q=[r,o,c1].find do |e| e.element == ele end 
    c1.innerHTML="<p>abs: #{q.get_rect.join(",")}<br>css: #{q.get_css_rect.join(",")}</p>" if q
    false   
  end
  
  r.show
 end
 
 
 def example2 document
  root,window = base(document,2)
  
  r=Rwt::Container.new(root.find(:test)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::RELATIVE|STYLE::BORDER_ROUND_LEFT|STYLE::FLAT) 
  r.innerHTML="<p></p>" 
  
  r.add o=Rwt::Container.new(r,:size=>[400,400],:style=>STYLE::CENTER|STYLE::ABSOLUTE|STYLE::RAISED)
  o.innerHTML="<p></p>"   
  
  o.add c1=Rwt::Button.new(o,'',:size=>[200,200],:style=>STYLE::RELATIVE|STYLE::CENTER|STYLE::SUNKEN)
    
  Rwt::UI::Collection.new(nil,[r,o,c1]).set_style('color','#666') 
  r.show
  
  Rwt::UI::Collection.new(nil,[r,o,c1]).set_style('color','#666').on('mouseover') do
    ele=window.event.target
    q=[r,o,c1].find do |e| e.element == ele end 
    c1.innerHTML="<p>abs: #{q.get_rect.join(",")}<br>css: #{q.get_css_rect.join(",")}</p>" if q
    false   
  end
 end
 
 
 def example3 document
  root,window = base(document,3)
  
  r=Rwt::Container.new(root.find(:test)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::ABSOLUTE|STYLE::BORDER_ROUND_LEFT|STYLE::FLAT) 
  r.innerHTML="<p></p>" 
  
  r.add o=Rwt::Container.new(r,:size=>[400,400],:style=>STYLE::CENTER|STYLE::ABSOLUTE|STYLE::RAISED)
  o.innerHTML="<p></p>"   
  
  o.add c1=Rwt::Button.new(o,'',:size=>[200,200],:style=>STYLE::RELATIVE|STYLE::CENTER|STYLE::SUNKEN)
    
  Rwt::UI::Collection.new(nil,[r,o,c1]).set_style('color','#666') 
  r.show
  
  Rwt::UI::Collection.new(nil,[r,o,c1]).set_style('color','#666').on('mouseover') do
    ele=window.event.target
    q=[r,o,c1].find do |e| e.element == ele end 
    c1.innerHTML="<p>abs: #{q.get_rect.join(",")}<br>css: #{q.get_css_rect.join(",")}</p>" if q
    false   
  end
 end    
 
 launch
end
