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
    @style = style
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
  
  class StateStyles
    def []= k,v
      @states[k] = v
    end
    def [] k
      @states[k]
    end
    def states
      @states 
    end
    def initialize *o
      @states = {}
    end
    def get_property_value prop,state=:normal
      self.states[state].getPropertyValue(prop) || inherited_property(prop,state)
    end
  end
  
  class InstanceStateStyles < StateStyles
    def initialize obj
       super
      @instance = obj
    end
    def inherited_property prop,state=:normal
      @instance.class.class_state_styles(@instance.dom.context).get_property_value(prop,state)
    end
  end
  
  class ClassStateStyles < StateStyles
    def initialize klass,context
      super
      @class = klass
      @context = context
    end
    def inherited_property prop,state=:normal
      val = nil
      document = Rwt::DOM::Document.from_pointer_with_context(@context,@context.get_global_object.document.to_ptr)
      aa = @class.ancestors
      aa.delete_at(0)
      aa.find_all do |a|
        a.ancestors.find do |c| c == RObject end
      end.find do |a|
        val = a.class_state_styles(@context).get_property_value(prop,state)
      end
      val
    end
  end
  
  def init_instance_css
    return if @_instance_styles
    dom.setAttribute('id',dom_id)
    @_instance_styles = InstanceStateStyles.new(self)
    sheet = owner_document.get_style_sheets[0]
    sheet.addRule(rule="#{css_selector}","")
    @_instance_styles[:normal] = sheet.get_rule(rule).style
    [:focus,:hover,:active,:target,:'first-child'].each do |s|
      sheet.addRule(rule="#{css_selector}:#{s}","")
      @_instance_styles[s] =  sheet.get_rule(rule).style 
    end
    @_instance_styles
  end
  
  def instance_state_styles
    @_instance_styles ||= init_instance_css
  end
  
  def self.init_class_css context
    @_class_styles ||= {}
    return if @_class_styles[context]
    aa=ancestors
    aa.delete_at 0
    aa.find_all do |c|
      c.ancestors.index(RObject)
    end.each do |c|
      c.init_class_css context
    end
    document = Rwt::DOM::Document.from_pointer_with_context(context,context.get_global_object.document.to_ptr)
    @_class_styles[context] = ClassStateStyles.new(self,context)
    sheet = document.get_style_sheets[0]
    if sheet.has_rule?("#{css_selector}")
      rule = sheet.get_rule("#{css_selector}")
      @_class_styles[context][:normal] = rule.style
    else
      sheet.addRule(rule="#{css_selector}","")
      @_class_styles[context][:normal] = sheet.get_rule(rule).style
    end
    [:focus,:hover,:active,:target,:'first-child'].each do |s|
      if sheet.has_rule?("#{css_selector}:#{s}")
        sheet.addRule(rule="#{css_selector}:#{s}","")
        @_class_styles[context][s] = sheet.get_rule(rule).style
      else
        sheet.addRule(rule="#{css_selector}:#{s}","")
        @_class_styles[context][s] =  sheet.get_rule(rule).style 
      end
    end
    (@state_styles||={}).each_pair do |s,b|
      b.call @_class_styles[context][s],@_class_styles[context]
    end
    set_modifier_styles(context)
    @_class_styles[context]
  end
  
  def self.apply_style state=:normal,&b
    #(@state_styles||={})[state]=b
  end
  
  def self.apply_class cls,&b
    #(@modifier_styles||={})[cls]=b
  end
  def self.set_modifier_styles(context)
    document = Rwt::DOM::Document.from_pointer_with_context(context,context.get_global_object.document.to_ptr)
    sheet = document.get_style_sheets[0]
    (@modifier_styles||={}).each_pair do |m,b|
      if sheet.has_rule?("#{css_selector}.#{m}")
        rule = sheet.get_rule("#{css_selector}.#{m}")
        b.call rule.style,nil
      else
        sheet.addRule(rule="#{css_selector}.#{m}","")
        b.call sheet.get_rule(rule)['style'],nil
      end
    end
  end
  
  def apply_style state=:normal,&b
    #b.call instance_state_styles[state],instance_state_styles
  end
  
  def self.class_state_styles context
    @_class_styles ||= {}
    @_class_styles[context] ||= init_class_css context
  end  

  [:background_color,:color,:width,:height,:border_color,:border_style,:border_radius,:display].each do |m|
    f=camel_case(m)

    define_method m do
      @_style.send(f)
    end
    
    define_method m.to_s+"=" do |val|
      @_style.send(f+"=",val)
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
  
  def flex v=nil
    s=get_computed_value '-webkit-box-flex'
    return s if !v
    style['-webkit-box-flex']=v
  end
  
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
  attr_reader :style
  def initialize dom
    @_dom = dom
    @_listeners = {}
    a=self.class.ancestors
    buff = []
    a[0..a.index(RObject)].each do |c|
      buff << "Rwt#{c}".gsub("::",'')
    end
    dom.className = buff.join(" ")
    @_style = @style = dom.style
  end  
  #~ def self.new *o
    #~ @_class_styles ||= {}
    #~ ret = allocate
    #~ ret.send :initialize,*o
    #~ #init_class_css ret.dom.context if !@_class_styles[ret.dom.context]
    #~ ret 
  #~ end
  
  def show
    style.display = @_display
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
      style.overflow = 'hidden'
    end
    
    if ['both',true,:both,3].index(resize)
      return style.resize = 'both'
    end
    if ['vertical',:vertical,1].index(resize)
      return style.resize = 'vertical'
    end
    if ['horizontal',:horizontal,2].index(resize)
      return style.resize = 'horizontal'
    end
    style.resize = 'none'
  end
  
  def get_computed_value key
    dom.context.get_global_object.window.getComputedStyle(dom)[key]
  end
  
  def hide
    @_display = get_computed_value('display')
    style.display = "none"
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
	    style.overflow = s.last
	  elsif [:x,0,'x'].index(axis)
	    style.overflowX = s.last	  
	  elsif [:y,1,'y'].index(axis)
	    style.overflowY = s.last	  
	  end
	end
  end
  
  def get_resizable
    style['resize'] != 'none'
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
  @@f = nil
  def initialize parent,base = "div"
    #p [@@f,:at_at_f_eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee]
    @@f ||= JS.execute_script(@@c||=parent.context,"""
      var a = function(base,par) {
        ele = document.createElement(base);
        par.appendChild(ele);
        return(ele);
      }
      a;
    """)
    parent = RObject.new(parent) unless parent.is_a?(RObject)
    super @@f.call(base,parent.dom)
    parent.on_adopt self
    style['-webkit-box-sizing'] = 'border-box'
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
  end
  
  def on_adopt child
   #child.add_class "boxed"
   @@e ||= JS.execute_script dom.context,"""
     var d = function(sty) {
       sty['-webkit-box-flex'] = 1;
     };
     d
   """
   child.style['-webkit-box-flex'] = 1;
  end
end

class VBox < Box
  def initialize *o
    super
    style['-webkit-box-orient'] = "vertical"
  end
end

class HBox < Box
  def initialize *o
    super
    style['-webkit-box-orient'] = "horizontal"
  end
  def on_adopt child
    super
    child.width = "100%"
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
    style.overflow = "hidden"
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
    style['margin-top']='3px'
  end
  def src
    dom["src"]
  end
  def src= val
    dom.src=val
  end
end

class Panel < VBox
end

class HAttr < VBox
  def initialize *o
    super
    style['-webkit-box-align']='center'
  end
end

class Iconable < HAttr
  def initialize parent,icon=nil,c_base="div",*o
    super parent,c_base,*o
    @inner = HBox.new self
    style['-webkit-box-align'] = 'stretch'
    @inner.style['-webkit-box-align'] = 'center'
    @icon = Image.new(@inner,icon)
    @icon.hide if !icon
    @icon.width = 16
    @icon.height = 16
    @content = Widget.new(@inner)
    style.overflow = 'hidden'
  end

  def align orient = :left
    if orient == :left
      style['-webkit-box-align'] = 'stretch'
      return
    end
    style['-webkit-box-align'] = 'center'  
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
  apply_style :hover do |s,ss|
    next unless gradient=ss.get_property_value("background-image")
    from,to = gradient.scan(/rgb\(.*?\)/).map do |rgb|
      rgb.scan(/[0-9]+/).map do |a| a.to_i end
    end
    from = Color::RGB.new(*from).lighten_by(50)
    to = Color::RGB.new(*to).lighten_by(50)
    s['background-image'] = "-webkit-linear-gradient(top,#{from.html},#{to.html})"
  end
  apply_style :active do |s,ss|
    next unless gradient=ss.get_property_value("background-image")
    from,to = gradient.scan(/rgb\(.*?\)/).map do |rgb|
      rgb.scan(/[0-9]+/).map do |a| a.to_i end
    end
    from = Color::RGB.new(*from).darken_by(90)
    to = Color::RGB.new(*to).darken_by(90)
    s['background-image'] = "-webkit-linear-gradient(top,#{from.html},#{to.html})"
  end
  def initialize par,value = "",*o
    super par,*o
    self.text = value
    align :center
  end
end

class Label < Iconable
  def initialize par,value = "",*o
    super par,*o
    #self.text=value
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
    HTML = "<html><head><style type='text/css'>#{open('./rwt-styles.css').read}</style></head><body></body></html>"
    THEME = Theme.new
    attr_reader :images
    def initialize theme=THEME,*o
      super(HTML,f="file://#{File.expand_path(File.dirname(__FILE__))}")
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
      @d ||= Rwt::DOM::Document.from_pointer_with_context(global_object.context,global_object.document.to_ptr)
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
  def on_adopt c
    super
    return unless c.is_a? AcordionPanel
    @children << c
    c.toggle.on :click do
      draw(c)
    end
    draw  
  end
  def draw active=@children[0]
    return if @children.empty?
    @children.each do |c|
      c.add_class "collapsed"
      c.remove_class "first"
      c.remove_class "last"
      c.toggle.remove_class "first"
      c.toggle.remove_class "last"
    end
    @children.first.replace_class "last","first"
    @children.last.replace_class "first","last"
    @children.first.toggle.replace_class "last","first"
    @children.last.toggle.replace_class "first","last"
    return if !active
    active.remove_class "collapsed"
    active.toggle.remove_class "last"
  end
end

class AcordionPanel < Panel
  apply_class "collapsed" do |s,ss|
    s.display = 'none'
  end
  class Toggle < Button
    apply_style do |s,ss|
      s.maxHeight="16px"
      s['-webkit-box-flex'] = 0
      s['-webkit-border-radius'] = '0px'
    end
    apply_class "first" do |s,ss|
      s['-webkit-border-top-left-radius'] = '3px'
      s['-webkit-border-top-right-radius'] = '3px'
    end
    apply_class "last" do |s,ss|
      s['-webkit-border-bottom-left-radius'] = '3px'
      s['-webkit-border-bottom-right-radius'] = '3px'
    end
    def initialize par,control,*o
      super par,*o
      @control = control
    end
  end
  attr_reader :toggle
  apply_style do |s,ss|
    s['-webkit-border-radius']='0px'
  end
  apply_class "last" do |s,ss|
    s['-webkit-border-bottom-left-radius'] = '3px'
    s['-webkit-border-bottom-right-radius'] = '3px'
  end
  def initialize par,*o
    @toggle = Toggle.new(par,control=self)
    super par,*o
    add_class "collapsed"
  end
end

class ScrollArea < VBox
end

class Grid < VBox
  class Column
    attr_accessor :object
    def text
      @text ||= @object ? @object.text : ''
    end 
    def text= val
      @text = val
      @object.text = text if @object
      val
    end
    def width= i
      @width = i
    end
    def width
      @width ||= 100
    end
    def initialize text='',icon=nil
      self.text = text
      @icon = icon
    end
    def has_icon?
      !!@icon
    end
  end
  class Cell < Widget
    def initialize par,grid,val="",*o
      super par,*o
      self.text=val
      @grid = grid
    end
  end
  class IconCell < Iconable
    def initialize par,grid,val="",icon=:test,*o
      super par,icon,*o
      self.text=val
      @grid = grid
    end
  end
  class Row < HBox
    attr_reader :cells
    def initialize *o
      super
      @cells = []
    end
  end
  class Header < Row
    class Item < Button
      def initialize par,grid,*o
        super par,*o
        @grid = grid
      end
      def set col
        self.text = col.text
        style.minWidth = style.maxWidth = col.width
        col.object = self
      end
    end
    def initialize *o
      super
      style.minHeight = '32'
      #style['-webkit-box-flex'] = 0
    end
    def create_column col,grid
      i = Item.new self,grid
      i.set(col)
      i
    end
    def [] i
      @cells[i]
    end
  end
  attr_reader :rows,:cols
  def initialize par,*o
    super
    @rows = []
    @cols = [Column.new]
    @data = nil
    @h = VBox.new self
    @h.style.overflow = 'hidden'
    @header = Header.new @h
    @inner = ScrollArea.new self
    @h.style.minHeight = '32px'
    @inner.on :scroll do |e|
      @h.dom.scrollLeft = @inner.dom.scrollLeft
    end
    @inner.style.overflow = 'auto'
  end
  def set_cols ca
    @cols = ca
    ca.each_with_index do |c,i|
      (col=@header[i]) ? col.set(c) : @header.create_column(c,self)
    end
    ca.last.object.style.maxWidth = 'inherit'
    set_data @data if @data
  end
  def set_data data=@data
    @data = data
    data.each_with_index do |row,i|
      r = @rows[i] ||= self.class::Row.new(@inner)
      row.each_with_index do |cell,ci|
        next if ci+1 > @cols.length
        renderer = :Cell
        renderer = :IconCell if @cols[ci].has_icon?
        c = r.cells[ci] ||= self.class.const_get(renderer).new(r,self,cell)
        c.style.minWidth = c.style.maxWidth = @cols[ci].width
      end
      r.cells.last.style.maxWidth = 'inherit' 
    end
  end
end
class RObject
  def flex q=nil
    return if !q
    if q == 0
      style['-webkit-box-flex'] = q
      return 
    end
    q = q.to_f
    q = 100 - q
    q = q/100
    style['-webkit-box-flex'] = q
  end
end
Rwt::App.run do |app|
  # runs in an preload
  app.images[:test] = "http://google.com/favicon.ico"
  app.images[:google] = "https://www.google.com/images/srpr/logo3w.png"

  app.onload do
    body = app.document.body
    vb = VBox.new body
    vb.height = "100%"
    #vb.width = "400px"
    hb = HBox.new vb
    ac = a = Acordion.new(hb)
    ap = AcordionPanel.new(a)
    ap.toggle.text = "First"
    TextBox.new(ap)
    ap = AcordionPanel.new(a)
    ap.toggle.text = "..."
    v=VBox.new(ap)
    w=Widget.new(v)
    Label.new(w,"A label\nfoo bar")
    TextBox.new(v,'').flex 0
    TextBox.new(v,'').flex 0
    h=HBox.new(v)
    h.flex 0
    Button.new(h,"ok")
    Button.new(h,"cancel")
    ap = AcordionPanel.new(a)
    ap.toggle.text = "Last"
    TextBox.new(ap)
    #pa = Widget.new hb
    #pa.style.overflow = 'hidden'    
    g = Grid.new(hb)
    #pa.flex 0.8
    ca = []
    bool = :test
    8.times do
      ca << Grid::Column.new("Column #{ca.length}",bool)
      bool = false
    end
    g.set_cols ca
    data = []
    50.times do
      row = []
      8.times do
        row << "#{data.length}:#{row.length}"
      end
      data << row
    end
    g.set_data data
    a.flex 33.33
    g.flex 66.66
  end
  
  app.display
end
