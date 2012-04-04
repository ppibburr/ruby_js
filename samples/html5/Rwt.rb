require "./lib/app"

class Border
  class Placement
    [:style,:color,:width].each do |m|
      define_method m do
        @style["border-#{@position}-#{m}"]
      end
      define_method m.to_s+"=" do |v|
        @style["border-#{@position}-#{m}"] = v
      end
    end
    
    def initialize style,pos,has_radius=false
      @position = pos
      @style = style
      @radius = has_radius        
    end
    
    [:right_radius,:left_radius].each do |m|
      f=("-webkit-border-pos-#{m}").gsub("_",'-')
      
      define_method m do
        @style[f.gsub('pos',@position.to_s)]
      end
      
      define_method m.to_s+"=" do |val|
        @style[f.gsub('pos',@position.to_s)] = val
      end
    end
  end
  
  [:style,:color,:width].each do |m|
    define_method m do
      @style["border-#{m}"]
    end
    define_method m.to_s+"=" do |v|
      @style["border-#{m}"] = v
    end
  end
  
	def top
	  Placement.new(style,:top,true)
	end
	def bottom
	  Placement.new(style,:bottom,true)
	end
	def right
	  Placement.new(style,:right)
	end
	def left
	  Placement.new(style,:left)
	end
  def radius= val
    @style['border-radius'] = val
  end
  
  attr_reader :style
  def initialize dom
    @style = dom.style
  end
end

def camel_case m
    a = m.to_s.split("_")
    a[0]+a[1..a.length-1].map do |q| q.capitalize end.join
end

class RObject
  [:background_color,:color,:width,:height,:border_color,:border_style,:border_radius,:display].each do |m|
    f=camel_case(m)

    define_method m do
      @_dom.style.send(f)
    end
    
    define_method m.to_s+"=" do |val|
      @_dom.style.send(f+"=",val)
    end
  end
  
  [:owner_document,:innerHTML,:inner_text].each do |m|
    a = m.to_s.split("_")
    f = a[0]+a[1..a.length-1].map do |q| q.capitalize end.join
    define_method m do
      @_dom.send(f)
    end
    
    define_method m.to_s+"=" do |val|
      @_dom.send(f+"=",val)
    end unless m == :owner_document
  end
  
  alias :ownerDocument :owner_document
  alias :text :inner_text
  alias :html :innerHTML
  alias :inner_html :html
  alias :"text=" :"inner_text="
  alias :"html=" :"innerHTML="
  alias :"inner_html=" :"html="
  
  def appendChild child
    object = child.is_a?(RObject) ? child.dom : child
    r = dom.appendChild object
    on_adopt(child)
    r
  end
  
  def on_adopt child
    # virtual
  end
  
  def border
    Border.new(dom)
  end
  
  def initialize dom
    @_dom = dom
    @_listeners = {}
  end
  
  def show
    self.display = @_display
  end
  
  def set_resizable resize=true
    if get_computed_value('overflow') == "visible"
      dom.style.overflow = 'hidden'
    end
    
    if ['both',true,:both,3].index(resize)
      return dom.style.resize = 'both'
    end
    if ['vertical',:vertical,1].index(resize)
      return dom.style.resize = 'vertical'
    end
    if ['horizontal',:horizontal,2].index(resize)
      return dom.style.resize = 'horizontal'
    end
    dom.style.resize = 'none'
  end
  
  def get_computed_value key
    dom.context.get_global_object.window.getComputedStyle(dom)[key]
  end
  
  def hide
    @_display = get_computed_value('display')
    self.display = "none"
  end
  
  def dom
    @_dom
  end
  
  def on(et,m=nil,&b)
    if dom["on#{et}"] and dom["on#{et}"] != :undefined
    else
      dom["on#{et}"] = proc do |this,event|
        event = Event.new(et,this,event)
        call_listeners(et,event)
      end
    end
    add_listener et, m ? m : b
  end
  
  def add_listener et,handle
    (@_listeners[et]||=[]) << handle
    @_listeners[et].length-1
  end
  
  def remove_listener et,id
    (@listeners[et]||=[]).delete_at(id)
  end
  
  def get_listeners(et=nil)
    if !et
      return @_listeners.map do |pair|
        pair[1]
      end
    end
    
    @_listeners[et]||=[]
  end
  
  def call_listeners et,event
    raise "Attempted to call every listener for all events" if et == nil
    val = nil
    get_listeners(et).each do |l|
      val = l.call(event)
      break if event.skipped?
    end
    return val
  end   
  
  def set_scrollable scroll=true,axis=true
	s = [
	  [:hidden,1,'hidden'],
	  [:none,false,0,'visible'],
	  [:auto,2,true,'auto'],
	  [:scroll,3,'scroll']
	].find do |q| q.index(scroll) end
	if s
	  if [:both,2,true,'both'].index(axis)
	    dom.style.overflow = s.last
	  elsif [:x,0,'x'].index(axis)
	    dom.style.overflowX = s.last	  
	  elsif [:y,1,'y'].index(axis)
	    dom.style.overflowY = s.last	  
	  end
	end
  end
  
  def get_resizable
    dom.style['resize'] != 'none'
  end  
  alias :'resizable?' :get_resizable
end

class Event
  attr_reader :type,:this,:event
  def initialize type,this,event
    @type,@this,@event = type,this,event
  end
  
  def skip
    @skipped = true
  end
  
  def skipped?
    @skipped
  end
    
  def target
    event.target
  end
end

class Widget < RObject
  def initialize parent,base = "div"
    parent = RObject.new(parent) unless parent.is_a?(RObject)
    super parent.ownerDocument.createElement(base)
    parent.appendChild self
    dom.style['-webkit-box-sizing'] = 'border-box'
  end 
end

class Container < Widget
  def initialize *o
    super
    @children = []
  end
end

class Bin < Container
  def on_adopt child
    raise "There can be only ONE!" if !@children.empty?
    super
  end
end

class Box < Container
  def initialize *o
    super
    self.display = "-webkit-box"
    dom.style['-webkit-box-align'] = "strecth"
  end
  
  def on_adopt child
    child.display = "block"
    child.dom.style['-webkit-box-flex'] = 1
  end
end

class VBox < Box
  def initialize *o
    super
    dom.style['-webkit-box-orient'] = "vertical"
  end
end

class HBox < Box
  def initialize *o
    super
    dom.style['-webkit-box-orient'] = "horizontal"
  end
end

class Tabbed < Container

end

class Acordion < Container

end

class Pager < Container

end

module Text
  def set_editable bool
    dom.set_attribute("contenteditable", !!bool)
  end
  
  def get_editable
    dom.get_attribute("contenteditable")
  rescue
    false
  end
  
  def value
    text
  end
  
  def value= v
    self.text=v
  end
  
  def initialize par,value,*o
    super par,*o  
    self.text=value
    set_editable(true)
    dom.style.overflow = "hidden"
  end
end

class TextBox < Widget
  include Text
  def initialize par,value = "",*o
    super par,value,*o
    set_scrollable :hidden
  end
end


class List < Container

end

class Image < Widget
  def initialize par,src,inline=false,base="img"
    super par,base
    display="inline-block" if inline
    if src.is_a?(Symbol)
      src = Rwt.THE_APP.images[src]
    end
    self.src = src
    dom.style['margin-top']='3px'
  end
  def src
    dom["src"]
  end
  def src= val
    dom.src=val
  end
end

class Iconable < Widget
  def initialize parent,icon=nil,c_base="div",*o
    super parent,c_base,*o
    @icon = Image.new(self,icon,true)
    @inner = Widget.new(self)
    inner.display = "inline-block" if icon
    p c_base
    @content = Widget.new(inner,c_base)
  end
  {:text=>:innerText,:html=>:innerHTML}.each_pair do |k,v|
    define_method k do
      @content.send(k,v)
    end
    
    define_method m=k.to_s+"=" do |v|
      @content.send(m,v)
    end
  end
  
  def icon
    @icon
  end
  
  private
  def inner
    @inner
  end
  def content
    @content
  end
end

class Input < Iconable
  include Text
end

class Button < Iconable
  def initialize par,value = "",*o
    super par,*o
    self.text=value
    border.color = "black"
    border.width = "1px"
    border.style = 'solid'
    border.radius = "5px"
  end
end

class Label < Iconable
  def initialize par,value = "",*o
    super par,*o
    self.text=value
  end
end

class ScrollView < Bin
  def initialize par,*o
    super
    set_scrollable :auto
    border.color = 'black'
    border.style = 'solid'
    border.width = '1px'
    set_resizable
  end
end

module Rwt
  class ImageMap
    attr_reader :object
    def initialize images=nil,ctx=nil
      @hash = {}
      @que = []
      @object = nil
      @init = nil
      
      if images.respond_to?(:each_pair)
        images.each_pair do |k,v|
          self.images[k] = v
        end
      elsif images.is_a?(Array)
        images.each do |src|
          load_image src
        end
      end
    end
    
    def []= k,v
      @hash[k] = v
      load_image(v)
      v
    end
    
    def [] k
      @hash[k]
    end
    
    def is_init?
      @init
    end
    
    def load_image src
      if is_init?
        object.src = src
        return self
      end
      @que << src
      self
    end
    
    def init(ctx=@ctx)
      return true if is_init?
      @object = JS.execute_script ctx,"new Image();"
      @init = true
    rescue
      @init = false
      return false
    end
    
    def load
      return false if !is_init?
      @que.clone.each do |src|
        @object.src = src
        @que.delete(src)
      end
      return true
    end
  end
  
  class Theme
    attr_reader :images
    def initialize
      @images = {}
      @css = {}
    end
  end
  
  def self.THE_APP
    App.instance
  end
  
  class App < RubyJS::App
    THEME = Theme.new
    attr_reader :images
    def initialize theme=THEME,*o
      super(*o)
      @images = ImageMap.new(theme.images)
      preload do |global|
        images.init global.context
        images.load
      end
    end
    
    class << self
      attr_reader :instance
    end
    
    def self.set_instance i
      @instance = i
    end
    
    def self.new *o
      ret = allocate
      ret.send :initialize,*o
      Rwt::App.set_instance ret
      return ret
    end 
  end
end

Rwt::App.run do |app|
  # runs in an preload
  app.images[:test] = "http://google.com/favicon.ico"
  app.images[:google] = "https://www.google.com/images/srpr/logo3w.png"

  app.onload do
    body = app.global_object.document.body
    
    sv=ScrollView.new body
    sv.width = 200
    Image.new(sv,:google)
    
    l=Label.new(body,"Foo")
    l.color = 'red'
    l.on :click do |*o|
      l.text = "bar"
      l.color = "blue"
    end
    
    l.on :mouseover do
      p :mouseover
    end
    
    b = Button.new(body,"click me",:test)
    i = Input.new(body,"gg")
    t = TextBox.new(body,open(__FILE__).read)
    t.height = 100
    
    l1 = Label.new(body,"flash",:test)
    clrs = ["green","red"]
    state = 0    
    
    GLib.timeout_add(200,333, proc do
      l1.color = clrs[state]
      state+=1
      state = 0 if state > 1
      true
    end, nil, nil)
  
    v = VBox.new body
    v.height = 100
    b = Button.new(v,"ff")
    b = Button.new(v,"ff")
    b.background_color="blue"
    b = Button.new(v,"ff")
    
    v = HBox.new body
    v.set_resizable true
    v.width = 100
    
    b = Button.new(v,"ff")
    b = Button.new(v,"ff")
    b.background_color="blue"
    b = Button.new(v,"ff")
  end
  
  app.display
end
