module Rwt
  class SizeNotify
    attr_reader :doc
    def initialize doc
      @doc = doc
      @watching={}
    end
    
    def start
      @running = true
    end
    
    def stop
      @running = false
    end
    
    def running?
      @running
    end
    
    def poll
      Collection.new(doc).find(".listen_resize").each do |e|
        if @watching[e] != (current=[e.clientWidth,e.clientHeight]) and @watching[e]
          w,h = @watching[e]
          nw,nh=current
          cw = nw-w
          ch = nh-h
          p 5
          e.onresize(cw,ch) if e['onresize'] and e['onresize'].is_a?(JS::Object) and e['onresize'].is_function
          p 6
        end
        @watching[e] = current
      end
    end
  end

  def self.init doc,o={}
    raise if !o.is_a? Hash
    o[:style] ||= File.join(File.dirname(__FILE__),'resources',"rwt_theme_default.css")
    o[:scripts] ||= []
    o[:scripts] << File.join(File.dirname(__FILE__),'resources',"uki.dev.js") 
    o[:scripts] << File.join(File.dirname(__FILE__),'resources',"uki-more.js")     
    JS::Style.load doc,o[:style]

    o[:scripts].each do |s|
      JS::Script.load doc.context,s
    end 
    
    size_notifier = SizeNotify.new(doc)
    
    size_notifier.start

    GLib::Idle.add 200 do
      size_notifier.poll if size_notifier.running?
      true
    end    
  end

  class Collection < Array  
    def initialize from,*o
      @from = from
      super(*o)
    end
    
    #def [] *o
     # find *o
    #end
    
    def bind *o,&b
      o.each do |e|
        each do |q|
          if q.is_a?(Rwt::Object)
            q.element.send(:"on#{e}=",b)
          else
            q.send(:"on#{e}=",b)     
          end
        end
      end
      self
    end
    
    def add_class n
      each do |o|
        o.className = (o.className + " #{n}").strip     
      end
    end
    
    def remove_class n
      each do |o|    
        o.className = o.className.gsub(Regexp.new("^#{n}$"),'')
        o.className = o.className.gsub(Regexp.new(" #{n}$"),'')
        o.className = o.className.gsub(Regexp.new("^#{n} "),'')
        o.className = o.className.gsub(Regexp.new(" #{n} "),' ')   
        o.className = o.className.strip   
      end     
    end
    
    def style k,v
    
    end
    
    def find_name q
      if @from.is_a?(Collection)
        @from.find! do |o| o.name == q.to_s end  
      elsif @from.is_a?(JS::Object)
        @from.get_elements_by_name(q.to_s)[0]
      elsif @from.is_a?(Rwt::Object)
        @from.element.ownerDocument.get_elements_by_name(q.to_s)[0]
      end      
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
    attr_reader :element,:parent,:shown
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
    
    def show
      Collection.new(self,[self]).remove_class("hidden")
      @shown = true
    end
    
    def hide
      return if @shown != true
      Collection.new(self,[self]).add_class("hidden")    
      @shown = false
    end
  end

  class Drawable < Object
    CSS_CLASS = "drawable"
    include Rect
    def initialize parent,*opts         
      opts << {} if opts.empty?
      raise unless (opts=opts[0]).is_a?(Hash)
      opts[:tag] ||= 'div'
      
      super(parent,opts[:tag])    
      element.className = (element.className + " #{CSS_CLASS}").strip      
      apply_default_size
      opts[:position] ||= [0,0]
      [:size,:position].each do |k|
        next unless opts[k]
        opts[k] = [opts[k]] unless opts[k].is_a?(Array)
        send("set_#{k}",*opts[k])
      end
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
      
      super
    end
  end

  class Container < Drawable
    CSS_CLASS = "container"
    attr_reader :children
    def initialize *o
      @children = []
      super *o
      element.className = (element.className + " #{CSS_CLASS}").strip      
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
    CSS_CLASS = "bin"
    def child
      children[0]
    end

    def add q
      return if children.length >= 1
      super q
    end
  end

  class Panel < Bin
    CSS_CLASS = "panel"
    class Handle < Container
      CSS_CLASS = "panel_handle"
      def initialize par,q,*o
        title = q
        if q.is_a? Hash
          o = [q]    
          title=nil    
        end    
        
        super par,*o
        
        Collection.new(self,[self]).add_class("panel_handle")
        
        add Label.new(self,title,:size=>Rwt::Size.get_size(:panel_handle))
        add @shade=Drawable.new(self,:size=>Rwt::Size.get_size(:panel_shade))
        
        toggle_state(:unshaded)
        
        @shade.style.cursor = "pointer"
        
        Collection.new(self,[@shade]).bind(:click) do
          parent.parent.toggle_state()
        end      
      end
      
      def toggle_state(s)
        case s
          when :shaded
            @shade.element.innerText = "[+]"
        else
          @shade.element.innerText = "[-]"
        end
      end
      
      def show *o
        super *o
        @shade.style.left = (@element.clientWidth.to_f-31).to_s+"px"
      end
    end
  
  
    attr_reader :handle
    def initialize par,q,*o
      title = q
      if q.is_a? Hash
        o = [q]    
        title=nil    
      end    
      
      super par,*o
      
      element.className = (element.className + " panel listen_resize").strip
      
      add c=@root=Container.new(self)
      c.add @l=Rwt::Panel::Handle.new(c,title.to_s)    
      @inner=Rwt::Bin.new(c,:size=>Rwt::Size.get_size(:panel_inner),:position=>[0,21]) 
      c.add @inner
      
      collection!.bind(:resize) do |t,cw,ch|
      p [cw,ch]
        if size[0] < 0
          size[0]=element.clientWidth
        else
          size[0]=size[0]+cw
        end
        
        if size[1] < 0
          size[1]=element.clientHeight
        else
          size[1]=size[1]+ch
        end
        @children.each do |c| c.show() end
        p element.clientHeight
      end
      
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
    
    def toggle_state
      h = @inner.element.client_height
      if @inner.shown
        @pre_shaded_size = size[1]
        size[1] = size[1] - h
        show
        @inner.hide
        @handle.toggle_state(:shaded)
      else
        size[1] = @pre_shaded_size
        show
        @handle.toggle_state(:unshaded)        
      end     
    end
    
    alias :show! :show
    def show  
      show!(nil)
      
      @root.show
      @handle.style.width = (@handle.parent.element.clientWidth.to_f-3).to_s+"px"
    end
  end
  
  class Window < Panel
    CSS_CLASS = "window"
    def initialize *o
      super
      element.className = (element.className + " window").strip
      style.position='fixed'
    end
  end

  class Scrollable < Bin
    CSS_CLASS = "scrollable"
  end
  
  class Rule < Drawable
    CSS_CLASS = "rule"
    def initialize *o
      super
      element.className = (element.className + " rule").strip
    end  
  end
  
  class HRule < Rule
    CSS_CLASS = 'hrule'
    def initialize *o
      super
    end
    
    def show()
      super()
    end  
  end
 
  class Label < Drawable
    CSS_CLASS = "label"
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
    CSS_CLASS = "entry"
    def initialize par,q,*o
      text = q
      if q.is_a? Hash
        o = [q]    
        text=nil    
      end
      
      super par,*o
      element.innerText = text.to_s     
      element.className = (element.className + " entry").strip
      element.contentEditable = true;
    end    
  end
  
  class TextView < Entry
    CSS_CLASS = "textarea"
    def initialize *o
      super
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
 
  class TreeList < Foriegn
    CSS_CLASS = "treelist"
    def initialize par,*o
      super

      begin
        @uki = JS.execute_script(parent.element.context,"uki;")
      rescue
        raise RuntimeError.new("resource uki-more.js not found")
      end

      @opts = o[0] ||= {}
      @data = @opts[:data]
    end
    
    def show
      super(true)
      return if @init
      @init = true
      @opts[:anchors] ||= DEF_OPTS[:anchors]
      
      if position[1] == 0
        position[1] = 1
        size[1] = size[1] - 1
      end

      @object = @view = @uki.call({ 
        :view=>'uki.more.view.TreeList', 
        :rect=>get_rect.join(" "),
        :anchors=>@opts[:anchors], 
        :multiselect => true, 
        :style => {:fontSize=>'11px', :lineHeight=>'11px'}
      })
      
      data(@data) if @data
      
      @view.attachTo(element)    
    end
    
    def data a=nil
      return @data=@view.data(a) if a and @view
      return @data = a if a 
      @data = @view.data
    end
    
    DEF_OPTS = {
      :anchors => 'left top right bottom'
    } 
  end 
  
  class Table < Foriegn
    CSS_CLASS = "table"
    def initialize par,*o
      super

      begin
        @uki = JS.execute_script(parent.element.context,"uki;")
      rescue
        raise RuntimeError.new("resource uki.js not found")
      end

      @opts = o[0] ||= {}
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
      
      @view.attachTo(element)    
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
  
  class Menubar < Drawable
    CSS_CLASS = "menubar"
    def initialize par,*o
      super
      
      self.className=("menu_bar")
    end
    
    def add text
      Menu.new(self,text)
    end
    
    def self.fill a,d
      i=d.add a[:label]
      (a[:children]||=[]).each do |c|
        fill(c,i)
      end
      
      if q=a[:activate]      
        if q.is_a?(Symbol)
          q=proc do
            i.send a[:activate]
          end
        end
        i.on_activate &q
      end
      i.id = a[:id].to_s if a[:id] 
      if a[:id]
        puts a
        puts i.class
        puts i.id
      end
    end
    
    def self.from_array par,a,*o
      mb = Menubar.new(par,*o)
      a.each do |m|
        fill(m,mb)
      end
      mb
    end
  end

  class Menu < Rwt::Object
    attr_accessor :label,:item
    def initialize par,text
      super par,'ul'
      
      Collection.new(self,[self]).add_class("menu")
      @item = Rwt::Object.new(self,'li') 
      @label = Rwt::Object.new(@item,'h2')  
      @label.element.innerText = text  
      @inner = Rwt::Object.new(@item,'ul')
      Collection.new(self,[@item]).add_class('menu_root_item')
      Collection.new(self,[@inner]).add_class("sub_menu")       
    end
    def add q
      MenuItem.new(@inner,q)
    end
  end

  class MenuItem < Rwt::Object
    attr_accessor :label
    def initialize par,text
      super par,'li'
      
      Collection.new(self,[self]).add_class("menu_item")
      @label = Rwt::Object.new(self,'span')  
      @label.element.innerText = text  
      element.name= text
      Collection.new(self,[self]).bind(:click) do |*o|
        @activate_event.call(*o) if @activate_event   
      end  
    end
    
    def add q
      if !@inner
        @inner = Rwt::Object.new(self,'ul')
        Collection.new(self,[@inner]).add_class("sub_menu")     
      end
      
      MenuItem.new(@inner,q)
    end
    
    def on_activate &b
      @activate_event = b
    end
  end
end

