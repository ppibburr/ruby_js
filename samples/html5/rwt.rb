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
    p f
      send(f)
    end
    
    define_method m.to_s+"=" do |val|
      send(f+"=",val)
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
  
  def on(et,m=nil,&b)
    #return
    @e||={}
    @@o ||= context.get_global_object['rwt_object_add_event']
    if @e[et]
    else
      @@o.call self,et.to_s do |this,event|
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


class RObject < JS::Object
  include Observable
  def self.css_selector
    ".Rwt#{name.gsub("::",'')}"
  end
  class << self
    alias :_new :new
  end
  def self.new *o
    r = allocate
    r.send :initialize,*o
    r
  end
  def self.cast *o
    r = allocate
    o.push false
    r.send :initialize,*o
    r
  end
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
    @@f ||= parent.context.get_global_object['rwt_widget_create']
    if !wrap
      ele = @@f.call parent,base,true
      parent = RObject.new(parent) unless parent.is_a?(RObject)
    else
      ele = parent
    end
    super ele
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
    style['-webkit-box-orient'] = "vertical"
  end
  def on_adopt child
    super
    child.height = "100%"
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
  def initialize par,src,inline=false,base="img"
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

class HAttr < VBox
  def initialize *o
    super
    style['-webkit-box-align']='center'
  end
end

class Iconable < HAttr
  def initialize parent,icon='',c_base="div",*o
    super parent,c_base,*o
    @inner = HBox.new self
    style['-webkit-box-align'] = 'stretch'
    @inner.style['-webkit-box-align'] = 'center'
    @icon = Image.new(@inner,icon)
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
      @content.send(v)
    end
    
    define_method m=k.to_s+"=" do |v|
      @content.send(m,v)
    end
  end
  
  def icon
    @icon
  end
  
  def set_icon q
    icon.src= q
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
  def initialize par,value="",icon="",*o
    super par,icon,'span'
  #  @content.extend Text
  #  @content.style['-webkit-box-pack']='stretch'
    #@content.set_attribute 'contenteditable',true
    style.overflow = "none"
    on :click do
      show_editor
    end
  end
  def show_editor
    return if @edit
      w=@content.get_computed_value "width"
      h=get_computed_value 'height'
     x = @content.offsetLeft
     x = x + @content.scrollLeft
     y = offsetTop
     y = y + scrollTop
     o = Widget.new(self,'input')
     o.set_attribute "type","text"
     o.style.position = 'absolute'
     o.style.top = y
     o.style.left = x
     o.style['minWidth'] = "#{w}"
     o.style['maxHeight'] = "#{h}"
     o.style.backgroundColor = 'inherit'
     o.style.borderWidth = '0px'
     append_child o
     o.focus
     @edit = true
     o.on :blur do
       o.hide
       self.text = o.value
       @edit = false
     end
  end
end

class Button < Iconable
  require 'color'
  def initialize par,value = "",icon=nil,*o
    super par,icon,'span',*o
    self.text = value
    @icon.hide if !icon
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
  module Cell
    def initialize par,grid,value='',*o
      super par,*o
      set_attribute 'tabindex',-1
      self.text = value
      @grid = grid
      wrap
    end
    def wrap 
      on :focus do
        @grid.cell_selected self
      end
      on :dblclick do
        @grid.cell_activated self
      end
      on :blur do
        @grid.cell_deselected self
      end
    end
    def self.extended q
      super
      q.wrap
    end
  end
  class TextCell < HBox
    include Cell
    def initialize *o
      super
      style['-webkit-box-align'] =  'center';
    end
  end
  class IconCell < Iconable
    include Cell
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
        on :click do
          @grid.header_item_clicked self
        end
      end
      def set col
        self.text = col.text
        style.minWidth = style.maxWidth = col.width
        col.object = self
      end
    end
    def initialize *o
      super
      style.minHeight = 26
      #style['-webkit-box-flex'] = 0
    end
    def create_column col,grid
      i = Item.new self,grid
      i.set(col)
      i
    end
    def cell i
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
    @h.style.minHeight = '26px'
    @h.style.maxHeight = '26px'
    @inner.on :scroll do |e|
      @h.scrollLeft = @inner.scrollLeft
    end
    @wrp_cells = {}
    set_attribute('tabindex',-1)
    @inner.set_attribute('tabindex',-1)
    @inner.style.overflow = 'auto'
    @inner.on :click do |event|
      t = event.event.target 
      if t.className.split(" ").map do |c| c.downcase end.index("rwtgridcell")
        cell_selected(t)
      end
    end
    @inner.on :dblclick do |event|
      t = event.event.target
      cell_activated(t) if t.className.split(" ").map do |c| c.downcase end.index("rwtgridcell")
    end
    @on_cell_activate = @on_cell_select = @on_cell_deselect = @on_header_item_click = proc do |q| p q end
  end
  def load_indicator
    @inner.load_indicator
  end
  def set_cols ca
    @cols = ca
    ca.each_with_index do |c,i|
      (col=@header.cell(i)) ? col.set(c) : @header.create_column(c,self)
    end
    ca.last.object.style.maxWidth = 'inherit'
    set_data @data if @data
  end
  def set_data data
    @data=data
    buff = []
    code = ""
    r=nil
    cells=[]
    has_d = nil
 #   @inner['innerHTML'] = ''
    @rows ||= []
    df = context.get_global_object.document.createDocumentFragment()
                    rx = /(tabindex\=\"-1\"\>)(.*?)(\<\/div\>)/

    data.each_with_index do |row,i|
     if i == 0 and !@rows[i]
      has_d = true
      r = @rows[i] ||= self.class::Row.new(df)
      row.each_with_index do |cell,ci|
        next if ci+1 > @cols.length
        renderer = :TextCell
        renderer = :IconCell if @cols[ci].has_icon?
        c = r.cells[ci] ||= self.class.const_get(renderer).new(r,self)
        c.text = cell
        c['row']=i
        c.style['display'] = c.get_computed_value('display')
        c.style.minWidth = c.style.maxWidth = @cols[ci].width
        if c.is_a?(IconCell)
          render_icon i,ci,c
        end
      end
      r.cells.last.style.maxWidth = 'inherit' 
   #   code = r['outerHTML']
   #   cells = code.scan rx
     elsif 0 == 9
       q=code
       row.each_with_index do |cv,ci|
             next if ci+1 > @cols.length
             q = q.gsub(cells[ci].join,cells[ci][0]+cv+cells[ci][2])
       end
         buff << q
     elsif !@rows[i]
       has_d = true
       df.appendChild d=r.cloneNode(true)
       
       a=d.getElementsByClassName("RwtGridCell")
       for x in 0..a.length-1
         cl = RObject.cast(a.item(x))
         cl.set_property('row',i)
         cl.set_property "innerText", row[x]
       end
       @rows[i] = d
     else
       d = @rows[i]
       a=d.getElementsByClassName("RwtGridCell")
       for x in 0..a.length-1
         cl = RObject.cast(a.item(x))
         cl.set_property('row',i)
         cl.set_property "innerText", row[x]
       end
     end
    end
      # df['innerHTML'] = df['innerHTML'].force_encoding("UTF-8") + (buff.join.force_encoding("UTF-8"))
      # @inner.getElementsByClassName("RwtGridRow").each_with_index do |r,i|
      #   r.getElementsByClassName("RwtGridCell").each do |c|
      #     c['row'] = i
      #   end
      # end
   # @inner.show
   if has_d
     @inner['appendChild'].call(df)
   end
  end
  def on_render_icon &b
    @render_icon = b
  end
  def render_icon r,c,cell
    (@render_icon||=proc do |*o| end).call r,c,cell
  end
  def on_header_item_click &b
    @on_header_item_click  = b
  end
  def header_item_clicked hi
    @on_header_item_click.call(hi)
  end
  def on_cell_activate &b
    @on_cell_activate  = b
  end
  def cell_activated cell
    @on_cell_activate.call cell
  end
  def on_cell_select &b
    @on_cell_select = b
  end
  def cell_selected cell
    @on_cell_select.call cell
  end
  def on_cell_deselect &b
    @on_cell_select = b
  end
  def cell_deselected cell
    @on_cell_deselect.call cell
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
  def box_flex i
    style['-webkit-box-flex'] = i
  end
end
class List < Grid
  def initialize *o
    super
    @on_item_select = @on_item_activate = proc do |q| p q end
  end
  def get_row c
    r = @rows.find do |r|
      r.cells.index(c)
    end
    return nil if !r
    ri = @rows.index(r)  
  end
  def on_item_activate &b
    @on_item_activate = b
  end
  def on_item_select &b
    @on_item_select = b
  end
  
  def item_activated idx
    @on_item_activate.call idx
  end
  def item_selected idx
    @on_item_select.call idx
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
