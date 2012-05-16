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
  def initialize style
    @style = style
  end
end

def camel_case m
    a = m.to_s.split("_")
    a[0]+a[1..a.length-1].map do |q| q.capitalize end.join
end


module Observable
  def self_id
    "#{self.class.css_selector.gsub(/^\./,'')}_#{object_id.to_s(16)}"
  end
  
  def css_selector
    "##{self_id}"
  end

  [:background_color,:color,:width,:height,:border_color,:border_style,:border_radius,:display].each do |m|
    f=camel_case(m)

    define_method m do
      style.send(f)
    end
    
    define_method m.to_s+"=" do |val|
      style.send(f+"=",val)
    end
  end
  
  [:owner_document,:innerHTML,:inner_text].each do |m|
    f = camel_case m.to_s
    a = m.to_s.split("_")
    define_method m do
      send(f)
    end
    
    define_method m.to_s+"=" do |val|
      send(f+"=",val)
    end unless m == :owner_document
  end
  
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
    object = child.is_a?(RObject) ? child : RObject.new(child)
    r = appendChild object
    on_adopt(child)
    r
  end
  
  def on_adopt child
    # virtual
  end
  
  def border
    Border.new(self)
  end

  attr_accessor :data

  def self.extended q
    q.instance_variable_set "@_listeners", {}  
  end
  def style
    @style ||= self['style']
  end
  def yield_method_to_js foo,m,*o
    send(m,*o)
  end

  #  self['style']
  #end  
  #~ def self.new *o
    #~ @_class_styles ||= {}
    #~ ret = allocate
    #~ ret.send :initialize,*o
    #~ #init_class_css ret.context if !@_class_styles[ret.context]
    #~ ret 
  #~ end

  
  def show
    style.display = @_display
  end
  
  def get_classes
    className.split(" ")
  end
  
  def has_class? c
    !!get_classes.index(c)
  end
  
  def remove_class c
    a = get_classes
    a.delete(c)
    self.className = a.join(" ")
  end
  
  def add_class c
    return c if has_class?(c)
    a = get_classes.reverse
    a.push(c)
    self.className = a.reverse.join(" ")
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
    context.get_global_object.window.getComputedStyle(self)[key]
  end
  
  def hide
    @_display = get_computed_value('display')
    style.display = "none"
  end
  
  def dom
    self
  end
  
  def load_indicator
    ls = @ld_ind ||= LoadingSpinner.new(self)
    ls.style.top = (clientHeight/2)-25
    ls.style.left = (clientWidth/2)-25
    ls.style['z-index'] = 1
    ls
  end

  @@o = nil
  def on(et,m=nil,&b)
    #return
    @e||={}
    if !@@o
      @@o = context.get_global_object['rwt_object_add_event']
      @@o.context = context
    end
    if @e[et]
    else;
      self["on#{et}"] = proc do |this,event|
        event = Event.new(et,this,event)
        call_listeners(et,event)
        nil
      end
      nil
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
  
  def self.create_css_rule document,selector
    sheet = document.get_style_sheets[0]
    sheet.add_rule selector
    rule = sheet.get_rule selector
  end
  
  def set_id
    self['id'] = self_id
  end
end

class FStore
  def initialize
  @funcs = {}  
  end
  def add q,*o
    o.each do |m|
      a=m.to_s.split("_")
      f = a.shift
      a = a.map do |q| q.capitalize end.join
      func = f+a
      @funcs[m] = q[func]
      class << self;self;end.class_eval do
        define_method m do |this,*o,&b|
          @funcs[m].this = this
          @funcs[m].call(*o,&b)
        end
      end
    end
  end
end



class RObject < JS::Object
  include Observable
  def self.css_selector
    ".Rwt#{name.gsub("::",'')}"
  end
  class << self
    attr_accessor :foo
  end
  class << self
    alias :_new :new
  end
  def self.new *o
    r = allocate
    r.send :initialize,*o
    r
  end
  def self.cast obj
    return obj if obj.is_a?(self)
    o = allocate
    m = RObject.instance_method(:initialize)
    m = m.bind o
    m.call(obj,false)
    o
  end
  
  @@i = {}
  def initialize o,bool=true
    super o.to_ptr 
    @context = o.context
    @_self = self
    if bool
    a=self.class.ancestors
    buff = []
    a[0..a.index(RObject)].each do |c|
      buff << "Rwt#{c}".gsub("::",'')
    end
    self.className = buff.join(" ")
    #self['method'] = method(:yield_method_to_js)
    end
    @_listeners = {}  
    end
    def self.finalize(id)
     #   puts "Object #{id} #{@@i[id]} dying at #{Time.new}"
    end  
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
  def initialize parent,base = "div",wrap=nil
    if !@@f
      @@f = parent.context.get_global_object.document
      @@f.store_function 'createElement','create_element'
    end
    if !wrap
      ele = @@f.create_element(base)
      parent = RObject.new(parent) unless parent.is_a?(RObject)
      parent.store_function 'appendChild','append_child'
      parent.append_child(ele)
    else
      ele = parent
    end
    super ele#,!wrap
    parent.on_adopt self if !wrap
    style['-webkit-box-sizing'] = 'border-box' if !wrap
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
   @@e ||= JS.execute_script context,"""
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
  end
  def on_adopt child
    super
    child.height = "100%"
  end
end

class HBox < Box
  def initialize *o
    super
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
    set_attribute("contenteditable", !!bool)
  end
  
  def get_editable
    get_attribute("contenteditable")
  rescue
    false
  end
  
  def value
    text
  end
  
  def value= v
    self.text=v
  end
end

class TextBox < Widget
  include Text
  def initialize par,value = "",*o
    super par,*o
    self.text = value
    set_scrollable :hidden
  end
end

class Image < Widget
  def initialize par,src='',inline=false,base="img"
    super par,base
    self.display="inline-block" if inline
    self.src=src
    style['margin-top']='3px'
  end
  def src= src
    if src.is_a?(Symbol)
      src = Rwt.THE_APP.images[src]
    end
    self['src'] = src  
  end
end

class Panel < VBox
end

class Box
  def align pos
    if pos == :center
      style['-webkit-box-align'] = 'center'
    else
      style['-webkit-box-align'] = 'strecth'
    end
    pos
  end
end

class Hattr < HBox
  CONTENT_CLASS = Widget
  ATTR_CLASS = Widget
  attr_accessor :_attr_pos,:_space_pos,:_content_pos
  def initialize *o
    super
    @_attr = self.class::ATTR_CLASS.new(self)    
    @_space = Widget.new(self)
    @_content = self.class::CONTENT_CLASS.new(self) 
    
    @_attr_pos = 0 
    @_space_pos = 1
    @_content_pos = 2    
      
    content.add_class("rwthattrcontent")
    attr.add_class("rwthattrattr")
    space.add_class("rwthattrspace")

    store_function "getElementsByClassName"

    attr_pos :left
  end

  def content;
    return @_content if @_content 
    @_content = self.class::CONTENT_CLASS.cast(children(@_content_pos))
  end
  def space; @_space ||= getElementsByClassName("rwthattrspace")[0]; end
  def attr
    return @_attr if @_attr
    @_attr = self.class::ATTR_CLASS.cast(children(@_attr_pos))
  end
  
  def attr_pos pos
    if pos == :right
      insertBefore space,attr
      insertBefore content,space
      @_attr_pos = 2
      @_space_pos = 1
      @_content_pos = 0
    else
      insertBefore space,content
      insertBefore attr,space
      @_attr_pos = 0 
      @_space_pos = 1
      @_content_pos = 2
    end 
  end
  
  def set_attr(obj)
    q=self['replaceChild']
    q.call obj,attr
    obj.add_class("rwthattrattr")
    @_attr = obj
  end
  
  def set_space i
    space.style.maxWidth = space.style.minWidth = i
  end
end

class HAttrBox < VBox
  class Layout < Hattr
    def initialize *o
      super
      style.overflow='none'
    end
    def text= v
      content.innerText = v
    end
    def value= v
      self.text = v
    end
    def html= v
      content.innerHTML = v
    end
    def text
      content.innerText
    end
    def value
      self.text
    end
    def html
      content.innerHTML
    end
  end
  attr_reader :inner
  def initialize *o
    super
    @inner = self.class::Layout.new(self)
    style.overflow='none'
  end
  def attr_pos pos
    @inner.attr_pos pos
  end
  def valign pos
    @inner.align pos
  end
  def text= v
    @inner.text=v
  end
  def value= v
    self.text=v 
  end
  def html= v
    @inner.html=v
  end 
  def text
    @inner.text
  end
  def value
    text
  end
  def html
    @inner.html
  end
end

class Iconable < HAttrBox
  class Layout < HAttrBox::Layout
    ATTR_CLASS = Image
    def initialize par,icon='',*o
      super par,*o
      set_icon icon
      set_space 2
    end
    def set_icon src
      if !src
        attr.hide
        space.hide
      else
        attr.show
        space.show
      end
      attr.src = src
    end
  end
  
  def initialize par,icon=nil,*o
    super par,*o  
    set_icon icon if icon  
  end
  
  def set_icon src
    @inner.set_icon src
    src
  end
end

class Label < Iconable
  def initialize par,text='',*o
    super par,*o
    valign :center
    self.text=text
  end
end

class Button < Label
  def initialize *o
    super
    align :center
  end
end

module Editable
  class Editor < Widget
    def initialize control,ele = nil
      ele = control if !ele
      super control,"input"
      @control = control
      set_attribute "type","text"
      on :blur do
        control.end_edit value
      end

      @control = control
      @ele = ele
    end
  
    def set_value
      self.value = @control.text
    end
   
    def set_style
      style.maxWidth = @ele.get_computed_value("width")
      style.maxHeight = @ele.get_computed_value("height")
      style.top = @ele.offsetTop.to_i
      style.left = @ele.offsetLeft.to_i - 4    
    end
   
    def show
      set_value()
      super
      set_style()
      focus()
    end
  end
  
  def edit_on event
    on event do
      @editor.show
    end
  end
  
  def end_edit v
    self.text = v
    @editor.hide
  end
  
  def initialize *o
    super
    @editor = create_editor
    @editor.hide
  end
  
  def create_editor
    @editor ||= self.class::Editor.new(self)
  end
end


class Input < Iconable
  include Editable
  
  def initialize par,val,*o
    super par,*o
    self.value = val
    valign :center
    edit_on :focus
  end
  
  def create_editor
    self.class::Editor.new(self,@inner.content)
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
    HTML = "<html><head><style type='text/css'>#{open('./rwt-styles.css').read}</style><script type=\"text/javascript\">#{open('./rwt.js').read}</script></head><body></body></html>"
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
  class Toggle < Button
    def initialize par,control,*o
      super par,*o
      @control = control
    end
  end
  attr_reader :toggle
  def initialize par,header="",*o
    @toggle = Toggle.new(par,control=self)
    super par,*o
    toggle.text = header
    add_class "collapsed"
  end
end

class ScrollArea < VBox
end

require './grid.rb'
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
  def box_flex i
    style['-webkit-box-flex'] = i
  end
end


class LoadingSpinner < RObject
  class Bar < RObject
    def initialize par
      super par['ownerDocument'].create_element('div')
      par.append_child self
      style['-webkit-box-flex']=0
      #style.opacity = 1
    end
    def style
      @style ||= self['style']
    end
  end
  def initialize par
    super par['ownerDocument'].create_element('div')
    par.append_child self
    style['-webkit-box-flex']=0
    @q = []
    12.times do
      @q << t=Bar.new(self)
      t.add_class 'foo'
    end

    def update step
    GLib.timeout_add(200, 300, (proc do
      step = 12
      if step == 12
        @q = @q.push(@q.shift)
      end
    
      for i in 1..12
        a = @q[i-1].get_classes.reverse
        a.delete_at 0
        a=a.reverse
        a.push "bar#{i}"
        @q[i-1]['className']=a.join(" ")
      end
      true
    end),nil,nil) if !@w
    @w = true
    end
  end
end
class Audio < RObject
  def initialize par,src=nil
    ele = par['ownerDocument'].create_element "audio"
    ele.set_attribute "controls","controls"
    super ele
    par['appendChild'].call self
    self.open(src) if src
  end
  def open(src)
    set_attribute "src",src
    self['load'].call()
    play()
  end
end
module Rwt
  module Util
    class Timer
      attr_reader :interval,:timer_func,:timer,:t_index,:globj
      def initialize ctx,interval=30,&b
        @interval = interval
        @globj = ctx.get_global_object
      
        @t_index = globj['timers'].length
        c = nil
        
        @timer_func = JS::Object.new ctx do
          if !stopped?
          @timer = globj.setTimeout("timers[#{@t_index}]()",@interval);
          b.call if b and c
          c = true
          end
        end
        
        globj['timers'][@t_index] = @timer_func
      end
      def interval= i
        raise "Argument must be Numeric" unless i.is_a?(Numeric)
        @interval = i
      end
      def run
        raise "Timer removed" if removed?
        return if @timer
        @timer_func.call
        nil
      end
      def start
        raise "Timer removed" if removed?
        @stopped = false
        @timer_func.call
      end
      def stop
        raise "Timer removed" if removed?
        @stop = true
      end
      def stopped?
        !!@stop
      end
      def remove!
        return if removed?
        stop
        @globj['timers'][@t_index]=:undefined
        @timer_func = nil
        @timer = nil
        @removed = true
      end
      def removed?
        !!@removed
      end
    end
  
    class Que < Array
      attr_reader :callbacks,:timer
      def initialize ctx,i=30
        @callbacks = {}
        @timer = Timer.new(ctx,i) do
          self.check
        end
        super()
      end
      def add sym, &b
        @callbacks[sym] = b
      end
      def check
        raise "Que removed" if removed?
        return if empty?
a = shift
          a.each_pair do |k,v|
            if (cb=@callbacks[k]).respond_to?(:call)
              cb.call v
            elsif respond_to?(k)
              send(k,v)
            end
          end

      end
      def run
        raise "Que removed" if removed?
        @timer.run
      end
      def stop
        @timer.stop
      end
      def start
        @timer.start
      end
      def stopped?
        @timer.stopped?
      end
      def remove!
        @timer.remove!
      end
      def removed?
        @timer.removed?
      end
    end
  end
end
class RObject
  def set_loading
    @ld_que ||= Rwt::Util::Que.new context
    load_indicator
    @ld_que.add :load do |v|
      load_indicator.hide
    end
    @ld_que.run
  end
  def set_loaded &b
    @ld_que << {:load=>nil}
    b.call
  end
  def que
    if !@que 
      @que = Rwt::Util::Que.new context
      @que.run
    end
    @que
  end
end

