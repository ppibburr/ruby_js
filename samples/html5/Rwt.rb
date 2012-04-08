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
  def self.css_selector
    ".Rwt#{name.gsub("::",'')}"
  end

  def dom_id
    "#{self.class.css_selector.gsub(/^\./,'')}_#{object_id.to_s(16)}"
  end
  
  def css_selector
    "##{dom_id}"
  end
  
  class InstanceStyles
    def []= k,v
      @states[k] = v
    end
    def [] k
      @states[k]
    end
    def states
      @states.keys   
    end
    def initialize obj
      @instance = obj
      @states = {}
    end
    def inherited_property prop,state=:normal
      val = nil
      @instance.class.ancestors.find_all do |a|
        a.ancestors.find do |c| c == RObject end
      end.find do |a|
        st = a.css_selector + (state == :normal ? "" : "#{state}")
        sheet = @instance.owner_document.get_style_sheets[0]
        if sheet.has_rule?(st)
          rule = sheet.get_rule(st)
          style = rule.style
          val = style.getPropertyValue(prop)
        end
      end
      val
    end
  end
  
  def init_instance_css
    return if @_instance_styles
    dom.setAttribute('id',dom_id)
    @_instance_styles = InstanceStyles.new(self)
    sheet = owner_document.get_style_sheets[0]
    sheet.addRule(rule="#{css_selector}","")
    @_instance_styles[:normal] = sheet.get_rule(rule).style
    [:focus,:hover,:active,:target].each do |s|
      sheet.addRule(rule="#{css_selector}:#{s}","")
      @_instance_styles[s] =  sheet.get_rule(rule).style 
    end
    @_instance_styles
  end
  
  def instance_styles
    @_instance_styles ||= init_instance_css
  end

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
    a=self.class.ancestors
    buff = []
    a[0..a.index(RObject)].each do |c|
      buff << "Rwt#{c}".gsub("::",'')
    end
    dom.className = buff.join(" ")
  end  
  
  def show
    dom.style.display = @_display
  end
  
  def get_classes
    dom.className.split(" ")
  end
  
  def has_class? c
    !!get_classes.index(c)
  end
  
  def remove_class c
    a = get_classes
    a.delete(c)
    dom.className = a.join(" ")
  end
  
  def add_class c
    return c if has_class?(c)
    a = get_classes.reverse
    a.push(c)
    dom.className = a.reverse.join(" ")
  end
  
  def replace_class c,nc
    remove_class c
    add_class nc
    nil
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
    dom.style.display = "none"
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
    child.height = "auto"
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

class Panel < Bin
end

class HAttr < HBox
  def initialize *o
    super
    dom.style['-webkit-box-align']='center'
  end
end

class Iconable < HAttr
  def initialize parent,icon=nil,c_base="div",*o
    super parent,c_base,*o
    @bump = Widget.new(self)
    @icon = Image.new(self,icon)
    @icon.height = 16
    @icon.width = 16
    @icon.hide if !icon
    @content = Widget.new(self)
    @icon.dom.style['-webkit-box-flex']=0
    @bump.dom.style['-webkit-box-flex']=0
    Widget.new(self).dom.style['-webkit-box-flex']=0
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
  require 'color'
  def self.col_l c,pct
    p [c,self,:hhhhh]
    a = c.scan(/rgb\(.*?\)/).map do |rg| rg.scan(/[0-9]+/).map do |s| s.to_i end end
    from = a[0]
    to = a[1]
    from = Color::RGB.new(*from).lighten_by(pct)
    to = Color::RGB.new(*to).lighten_by(pct)
    [from.html,to.html]
  end
  def self.col_d c,pct
    p [c,:col_d,self]
    pct = pct
    a = c.scan(/rgb\(.*?\)/).map do |rg| rg.scan(/[0-9]+/).map do |s| s.to_i end end
    from = a[0]
    to = a[1]
    from = Color::RGB.new(*from).darken_by(pct)
    to = Color::RGB.new(*to).darken_by(pct)
    p r = [from.html,to.html]
    p self
    r
  end
  def initialize par,value = "",*o
    super par,*o
    @bump.dom.style['-webkit-box-flex'] = 1
    dom.id = "foo"
    self.text = value
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
  
  module CSS
    class Sheet < JS::Object
      def self.new *o
        obj=o[0]
        return super if o[0].is_a? Hash
        from_pointer_with_context obj.context,obj.to_ptr
      end
      def add_rule selector,rule=""
        addRule selector,rule
      end 
      def get_rule selector
        rule = nil
        for i in 0..rules.length-1
          rule = Rule.new(rules[i])
          next if rule.type == 8.0
          break if rule.selector_text == selector.downcase
          rule = nil
        end
        rule
      end
      def has_rule? sel
        !!get_rule(sel.downcase)
      end
    end
    class Rule < JS::Object
      def self.new *o
        obj=o[0]
        return super if o[0].is_a? Hash
        from_pointer_with_context obj.context,obj.to_ptr
      end
      def style
        Style.new(self['style'])
      end
    end
    class Style < JS::Object
      def self.new *o
        obj=o[0]
        return super if o[0].is_a? Hash
        from_pointer_with_context obj.context,obj.to_ptr
      end
    end
  end
  
  module DOM
    class Document < JS::Object
      def get_style_sheets
        a = []
        for i in 0..styleSheets.length-1
          a << CSS::Sheet.new(styleSheets[i])
        end
        a
      end
    end
  end
  
  class App < RubyJS::App
    HTML = "<html><head><style type='text/css'>#{open('./rwt.css').read}</style></head><body></body></html>"
    THEME = Theme.new
    attr_reader :images
    def initialize theme=THEME,*o
      super(HTML,f="file://#{File.expand_path(File.dirname(__FILE__))}")
      p f
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
    
    def document
      d = Rwt::DOM::Document.from_pointer_with_context(global_object.context,global_object.document.to_ptr)
    end
    
    def self.new *o
      ret = allocate
      ret.send :initialize,*o
      Rwt::App.set_instance ret
      return ret
    end 
  end
end

class Acordion < VBox
  def add child
    child.toggle.on :click do
      bool = nil
      if child.content.get_computed_value('display') != 'none'
        child.content.hide
        bool = false
      else
        child.content.show
        bool = true
      end
      on_toggle_child.call(child,bool)
    end
  end
  def on_toggle_child &b
    b ? (@on_toggle_child = b) : (@on_toggle_child||=proc do |c| end)
  end
end

class AcordionPanel < VBox
  class Toggle < Button; 
    def initialize *o
      super
      p instance_styles.inherited_property("background-image")
      dom.style.height = '36px'
      dom.style["-webkit-box-flex"]=0
      dom.style["-webkit-border-bottom-right-radius"]="0px"
      dom.style["-webkit-border-bottom-left-radius"]="0px"
    end
  end
  class Content < VBox
    def initialize *o
      super
      #dom.style["border-top"]="0px none #fff"
      hide
    end
  end
  attr_reader :content,:toggle
  def initialize par,*o
    super
    @toggle = Toggle.new self,'test'
    @content = Content.new(self)
    par.add self
    par.on_toggle_child do |c,active|
      p active
      p c.dom.style.display
      if active
        content.replace_class "collapsed","expanded"
      else
        content.replace_class "expanded","collapsed"
      end
      p [content.get_classes,:fff]
    end
  end
end


Rwt::App.run do |app|
  # runs in an preload
  app.images[:test] = "http://google.com/favicon.ico"
  app.images[:google] = "https://www.google.com/images/srpr/logo3w.png"

  app.onload do
    body = app.document.body 
    pn = Panel.new(body)
    a = Acordion.new(pn)
    ap = AcordionPanel.new(a)
    TextBox.new(ap.content,"fff\nhhhh\njjjjjjj\n")
    a = Acordion.new(pn)
    ap = AcordionPanel.new(a)
    TextBox.new(ap.content,"fff\nhhhh\njjjjjjj\n")
    a = Acordion.new(pn)
    ap = AcordionPanel.new(a)
    TextBox.new(ap.content,"fff\nhhhh\njjjjjjj\n")
  end
  
  app.display
end
