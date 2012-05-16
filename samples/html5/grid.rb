if __FILE__ == $0
  require './rwt'
end
class Pager < HBox
  attr_reader :next,:prev,:menu,:first,:last,:current
  class Button < ::Button
    def initialize par,value, *o
      super par,*o
      self.text = value
      @inner.attr.hide
    end
  end
  class GoTo < Input
    def initialize *o
      super
      @inner.attr.hide
      edit_on :focus
    end
    def end_edit *o
      super
      parentNode.page(value.to_i)
    end
  end
  def initialize *o
    super
    flex 0
    @min = 0
    @max = 0
    @current = 0
    @first = Button.new(self,"<<")
    @prev = Button.new(self,"<")
    @goto = GoTo.new(self)
    @next = Button.new(self,">")
    @last = Button.new(self,">>")
    
    @first.on :click do
      page(@min)
    end
    @last.on :click do
      page(@max)
    end
    @next.on :click do
      page @current+1 unless @current == @max
    end
    @prev.on :click do
      page @current-1 unless @current == @min
    end
  end
  def on_page &b
    @on_page_cb = b
  end
  def set_page i
    @current = i
    @goto.value = i
  end 
  def page(i)
    @current = i
    @goto.value = i
    @on_page_cb.call(i) if @on_page_cb
  end
  def update len
    @max = len
  end
end
class Grid < VBox
  attr_reader :columns
  def focus_cell c
    c.focus(true) if c
    cell_selected(c) if c
    @inner.getElementsByClassName("selected").each do |r|
      r.remove_class "selected"
    end if c
    c.parentNode.add_class("selected") if c
  end
  def get_next_focus cell,dir
    i = cell.parent_node.cells.index(cell)
    case dir.to_i
    when 0
      return cell.previousSibling || ((row=cell.parentNode.previousSibling) ? row.cells.last : nil)
    when 1
      return cell.parentNode.previousSibling.cells[i] if cell.parentNode.previousSibling
    when 2
      return cell.nextSibling || ((row=cell.parentNode.nextSibling) ? row.cells.first : nil)
    when 3
      return cell.parentNode.nextSibling.cells[i] if cell.parentNode.nextSibling
    end
  end
  def set_expander_column i
    column = nil
    columns.each_with_index do |c,ci|
      c.set_expander(false)
      column = c if i == ci
    end
    column.set_expander(true) if column
    column
  end
  class Content < ScrollArea
    def initialize par,*o
      super
      on :scroll do |e|
        par.update_scroll scrollLeft
      end

      on :keydown do |e|
        cell = ownerDocument.activeElement
        k = e.event.keyCode;
        if k >= 37 && k <= 40 
          dir = k-37
          par.focus_cell(par.get_next_focus(cell,dir))
          e.event.preventDefault()
          false
        elsif k == 13
          par.cell_activated(cell)
        else
          true
        end
      end

      style.overflow = 'auto'
      
      on :mouseup do |event|
        t = ownerDocument.activeElement
        cell = t if t.className.split(" ").map do |c| c.downcase end.index("rwtgridcell")
        if cell
          par.focus_cell(cell)
        end
      end
      
      on :dblclick do |event|
        t = ownerDocument.activeElement
        cell = t if t.className.split(" ").map do |c| c.downcase end.index("rwtgridcell")
        if cell
          par.cell_activated(cell)
        end
      end
    end
  end
  
  def initialize par,page_at=nil,*o
    super par,*o
    set_id
    @rows = []
    @data = nil
    @h = VBox.new self
    @h.style.overflow = 'hidden'
    
    @header = Header.new @h
    @inner = Content.new self
    @pager = Pager.new(self)
    @h.style.minHeight = '26px'
    @h.style.maxHeight = '26px'
  
    on_cell_edited do |cell,value|
      true
    end
    
    @pager.on_page do |i|
      s = i*@page_at
      e = s+@page_at-1
      render(@data[s..e])
    end
    
    set_paging page_at
  end
  
  def update_scroll(amt)
    @h.scrollLeft = amt 
  end
  
  def set_paging amt
    if !amt
      @pager.hide
    else
      @page_at = amt
    end
  end
  
  def rows
    @inner.getElementsByClassName("rwtgridrow").map do |e| Row.cast(e) end
  end
  
  def set_columns data
    @columns = data
    expander = nil
    data.each_with_index do |c,i|
      rule = Observable.create_css_rule self['ownerDocument'],"##{self_id} * * .column#{i}"
      expander = true if c.is_expander?
      
      c.set_style(rule)
      
      if item = @header.items[i]
      else
        item = Header::Item.new(@header,self) 
      end 
      
      c.attach(item)
      item.add_class "column#{i}"
    end
    
    set_expander_column 2
    data.last.set_expander() if !expander
  end
  
  def display data
    f = FStore.new()
    f.add(self['ownerDocument'],
                    :append_child,
                    :create_document_fragment,
                    :get_elements_by_class_name,
                    :clone_node) 

    ca = []
    _rows = rows()
    cloning_first = false
    
    data.each_with_index do |r,ri|
      if _rows.empty?
        cloning_first = true
        row = Row.new(@inner)
      
        r.each_with_index do |v,ci|
          column = columns[ci]
          ca << cell = column.cell_type.new(row)
          cell.add_class "column#{ci}"
        end
        
        w = 0
        columns.map do |c| w += c.width end
        @header.style.minWidth = (row.style.minWidth = w)+26
        _rows << row
      elsif ri == _rows.length
        r.each_with_index do |c,ci|
          columns[ci].renderer.render ca[ci],c
        end
      
        row = Row.cast(f.clone_node(_rows[0],true))
        cell = row.firstChild
      
        for ci in 0..r.length-1
          cell=columns[ci].cell_type.cast(cell)
          cell._content_pos = ca[ci]._content_pos
          cell._attr_pos = ca[ci]._attr_pos
          cell._space_pos = ca[ci]._space_pos
          cell = cell.nextSibling
        end
        
        f.append_child @inner,row
        _rows << row
      else
        row = _rows[ri]
        cell = row.firstChild
        
        r.each_with_index do |c,ci|
          columns[ci].renderer.render cell,c
          cell = cell.nextSibling
        end
      end
    end
    
    if data.length < rows.length
      qi = rows.length-data.length
      dt = []
    
      columns.each do |qc|
        dt << ""
      end
    
      for ni in 0..qi-1
        row = _rows[_rows.length-1-ni]
        cell = row.firstChild
        columns.each_with_index do |c,ci|
          columns[ci].renderer.render cell,""
          cell = cell.nextSibling
        end
      end
    end 
    
    data[0].each_with_index do |c,ci|
      columns[ci].renderer.render ca[ci],c
    end if cloning_first
  end
  
  def cell r,c
    if row=rows[r]
      row.cells[c]
    end
  end
  
  def set_data data
    @data = data
    if @page_at
      @pager.set_page 0
      render data[0..@page_at-1]
      @pager.update(((@data.length/@page_at.to_f)-1).ceil.to_i)
    else
      render data
    end
  end
  
  # allows to show the widget first then render content 
  def render data
    p [data.length,:len]
    que.add :data do |data|
      x=Time.now.to_f
      display data
      p Time.now.to_f - x
    end
    que << {:data=>data}
  end
  
  class Row < HBox
    def initialize *o
      super
    end
    def cells
      getElementsByClassName("rwtgridcell").map do |e| Cell.cast(e) end
    end
    def each_cell
      i = 0
      while cell = firstChild
        yield cell,i
        i += 1
      end
    end
  end
  
  class Cell < Hattr
    def initialize *o
      super
      set_attribute('tabindex',-1)
      align :center
      attr.hide and space.hide  if self.class == Grid::Cell

      content.add_class "cellcontent"
    end
    def coords
      return parentNode.parentNode.parentNode.rows.index(parentNode),parentNode.cells.index(self)
    end
  end
  
  class IconCell < Cell
    ATTR_CLASS = Image
  end
  
  class Header < HBox
    class Item < Button
      def initialize par,grid,*o
        super par,*o
        on :click do
          grid.header_click(self)
        end
      end
    end
    def items
      getElementsByClassName("rwtgridheaderitem").map do |e|
        Item.cast(e)
      end
    end
  end
  
  class Column
    attr_reader :renderer,:cell_type,:sortable,:icon,:label,:can_edit,:min_width,:width,:max_width,:style,:can_edit,:editor
    def initialize label="",icon=nil,props={}
      default = {:renderer => TextRenderer.new,
      :cell_type => Grid::Cell,
      :label => label,
      :icon => icon,
      :min_width => 50,
      :max_width => 'inherit',
      :width => 50,
      :can_edit=>true}
      default.each_pair do |k,v|
        props[k] = v unless props[k]
      end
      props.each_pair do |k,v|
        instance_variable_set("@#{k}",v)
      end
    end
    
    def is_expander?
      !!@expand
    end
    
    def set_expander bool = true
      @expand = bool
      render
      bool
    end
    
    def render
      h = @item
      return unless h
      if @style
        style['min-width'] = width.to_s+"px";
        style['max-width'] = is_expander? ? 'inherit' : width.to_s+"px"
        style.width = width.to_s+"px"
        style['-webkit-box-flex'] = 1.to_s 
      end
      h.text = @label
      h.set_icon @icon 
      nil
    end
    class Editor < Widget
      def initialize par,tag="input"
        super
        set_attribute "type","text"
        on :blur do
          hide
          @control.parentNode.focus
        end
        
        on :keydown do |e|
          k = e.event.keyCode;
          if k == 27
            blur
          elsif k == 13
            end_edit
          end
        end
      end
    
      def set_value v
        self.value = v
      end
     
      def set_style
        style.maxWidth = @control.get_computed_value("width")
        style.maxHeight = @control.get_computed_value("height")
        style.top = @control.offsetTop.to_i
        style.left = @control.offsetLeft.to_i - 4  
        style.top = style.top.to_i - @control.parentNode.parentNode.parentNode.scrollTop.to_i 
        style.left = style.left.to_i - @control.parentNode.parentNode.parentNode.scrollLeft.to_i  
      end
     
      def show
        set_value(@control.text)
        super
        set_style()
        focus()
        self['select'].call(true)
      end
      def display(control)
        @control = control
        show
      end
      def end_edit
        @control.text = value if q=@control.parentNode.parentNode.parentNode.parentNode.cell_edited(@control.parentNode,value)
        blur
      end
    end
    def attach item
      @item = item
      @editor = self.class::Editor.new(@item) if can_edit
      @editor.hide
      render
    end
    def set_style rule
      @style = rule.style
      @style
    end
    def set_label v
      @label = v
      @item.text = @label if @item
      v
    end
    def set_icon i
      @icon = i
      @item.set_icon(i) if @item
      i
    end
    def set_width w
      @width = w
      @item.style.width = w if @item
      w
    end
    def set_max_width w
      @max_width = w
      @item.style.maxWidth = w if @item
      w
    end
    def set_min_width w
      @min_width = w
      @item.style.minWidth = w if @item
      w
    end
  end
  
  class TextRenderer
    def render c,data
      c.content.innerText = data.to_s
    end
  end
  
  class IconTextRender < TextRenderer
    def render c,*data
      super c,data[0]
      c.attr.src = data[1]||:test
    end
  end
  
  def set_loading
    @inner.set_loading
  end
  [:header_click,:cell_selected].each do |m|
    define_method "#{m}" do |item|
      cb = instance_variable_get("@#{m}_cb")
      cb.call(item) if cb
    end
    define_method "on_#{m}" do |*o,&b|
      instance_variable_set("@#{m}_cb",b)
    end
  end
  def on_cell_activated &b
    @cell_activated_cb = b
  end
  def cell_activated cell
    if (column=columns[cell.coords[1]]).can_edit
      column.editor.display(cell.content)
    else
      @cell_activated_cb.call(cell) if @cell_activated_cb
    end
  end
  def on_cell_edited &b
    @cell_edited_cb = b
  end
  def cell_edited cell,value
    return @cell_edited_cb.call(cell,value)
  end
end

class List < Grid
  def initialize *o
    super
    on_cell_activated do |c|
      row_activate(c.parentNode,c.coords[1])
    end
    on_cell_selected do |c|
      row_select(c.parentNode,c.coords[1])
    end
  end
  
  [:row_activate,:row_select].each do |m|
    define_method m do |r,ci=nil|
      cb = instance_variable_get("@on_#{m}_cb")
      cb.call r,ci if cb
    end
    define_method "on_#{m}" do |&b|
      instance_variable_set("@on_#{m}_cb",b)
      b
    end
  end
end

if __FILE__ == $0
Rwt::App.run do |app|

  app.images[:test] = "http://google.com/favicon.ico"
  app.images[:google] = "https://www.google.com/images/srpr/logo3w.png"
  app.images[:search] = "http://www.veryicon.com/icon/16/System/Must%20Have/Search.png"
  app.onload do
 
    body = app.document.body
    app.global_object.timers=[]
    pa = Panel.new(body,nil,true)
    vb = VBox.new(pa)
    g = List.new(vb)
    
    d = []
    i = 0
    305.times do
      r = []
      for c in 0..2
        r << "#{i}:#{c}"
      end
      d << r
      i+=1
    end
    
    g.set_columns [
      Grid::Column.new('foo',:test,:renderer=>Grid::IconTextRender.new,:cell_type=>Grid::IconCell,:width=>100),
      Grid::Column.new('bar',nil,:width=>300),
      Grid::Column.new('moof',nil,:width=>100)
    ]
    
    g.set_data(d)
    g.on_header_click do |item|
      p item
    end
    g.on_row_select do |row,ci|
      p row,ci
    end
    g.on_row_activate do |row,ci|
      p row,ci
    end
    g.on_cell_edited do |cell,value|
      p value
      true
    end
  end
  
  app.display
end
end 
