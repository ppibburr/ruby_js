if __FILE__ == $0
  require 'rwt2'
end

module Rwt
  class ShiftBox < HBox
    attr_accessor :right_expander,:left_expander,:inner
    def initialize *o
      super
      
      add! @left_expander = l = Rwt::Drawable.new(self,:size=>[30,20])
      add! @inner = Rwt::HBox.new(self,:size=>[-1,20]),1
      add! @right_expander = r = Rwt::Drawable.new(self,:size=>[30,20])

      l.innerText = ' << '
      r.innerText= " >> "

      @_child_parent = @inner

      r.on('click',method(:step_right))
      
      l.on('click',method(:step_left))

      @_offset = 0
    end
    
    def step_left *o
      if inner.children[1].shown and @left_expander.shown
        @left_expander.hide
        #show false,false,true
      end

      if !@right_expander.shown
        @right_expander.show
       # show false,true,true
      end
      
      return if inner.children[0].shown
      
      inner.children.reverse[@_offset+1].hide
      c=inner.children.find() do |c| c.shown end
      if c
        idx = inner.children.index(c) - 1
        p [:idx,idx]
        inner.children[idx].show if idx >= 0
      end
      @_offset += 1
    end
    
    def step_right *o
      if @_offset == 1 and @right_expander.shown
        @right_expander.hide
        #show false,true,false;
      end
      
      return if @_offset == 0
      
      if !@left_expander.shown
        @left_expander.show
        #show false,true,(@right_expander.shown ? true : false)
      end
      
      inner.children.reverse[@_offset].show
      @_offset -= 1
    
      if ch=inner.children.find() do |c| c.shown end
        ch.hide
      end
    end
  
    def show
      super
    end
    
    def show c=true,l=false,r=false
      super()
      [@right_expander,@left_expander].map do |c| style.cursor='pointer' end
      @right_expander.hide if !r
      @left_expander.hide if !l
      return unless c
      bs = 0
      
      inner.children.each do |c|
        bs += c.get_size.width
      end
      p [:bs,bs];ox = get_size.width-@right_expander.get_size.width-@left_expander.get_size.width
      if bs > ox
        rev = inner.children.reverse
        cnt = 0
        p [:here]
        until bs <= ox
          ts=rev[cnt].get_size.width
          rev[cnt].hide
          cnt += 1
          bs -= ts
        end
        
        if cnt > 0
          if !@right_expander.shown
            @right_expander.show
            show false,false,true
          end
        end
        
        @_offset = cnt
      end
    end
    
    def show_expander(orient=:right)
      raise ArgumentError.new("expect symbol or string of 'right' or 'left'") unless [:left,:right].index(orient.to_sym)
      send("#{orient}_expander").show
    end
    
    alias :'add!' :add
    
    def add o      
      inner.add o,1
  
      return o
    end
  end
  
  module Book
    attr_reader :control,:active
    def initialize *o
      super
    end
    
    def index pg
      pages.index(pg)
    end
    
    def page(i)
      pages[i]
    end
    
    def pages
      children[1..children.length-1]
    end
    
    def show
      super
      pages.each do |pg| pg.hide end
      (@active||=page(0)).show
    end
    
    def set_active page
      pages.each_with_index do |pg,i|
        pg.hide unless page == pg
        l=pg.label
        unless (i == index(page)+1)
          l.style['border-bottom-left-radius']='' 
        else
          l.style['border-bottom-left-radius']='3px' 
        end
        unless (i == index(page)-1)
          l.style['border-bottom-right-radius']='' 
        else
          l.style['border-bottom-right-radius']='3px' 
        end
      end
      @active = page
      @active.show unless @active && @active.shown
      @active
    end
    
    class Page < Rwt::Container
      attr_reader :book,:label
      def initialize book,control,l,*o
        super book,*o
        label=control.add(l,self)
        @label = label
        @book = book
      end
      
      def show
        super
        style['border-top']=''
      end
      
      def index
        book.pages.index(self)
      end
    end
  end
  
  class Tab < Drawable
    def default_style
      STYLE::BORDER_ROUND
    end
    attr_reader :page
    def initialize par,pg,l,*o
      super par,*o

      self.innerText = l;p l
      
      @page = pg
      
      style.minWidth='50px'
      style.cursor = 'pointer'
            
      on('click', method(:on_activate))
    end
    
    def on_activate *o
      page.book.set_active page
      style['border-bottom'] = ''
      style['border-bottom-left-radius']=''
      style['border-bottom-right-radius']=''
      style.top = (get_css_position.y - 3).to_s+"px"
    end
  end
  
  class TabBox < ShiftBox
    def add l,pg
      o=Tab.new(inner,pg,l,:size=>[50,20],:style=>STYLE::DEFAULT|STYLE::BORDER_ROUND)
      super o
      o
    end
  end
  
  class TabBook < VBox
    include Book
    def initialize *o
      super
      add! @control=TabBox.new(self,:size=>[-1,20]),0,1
    end
    
    alias :'add!' :add
    
    def add l
      add! o = Book::Page.new(self,control,l,:style=>STYLE::DEFAULT|STYLE::BORDER_ROUND_BOTTOM),1,true
      
      return o
    end
  end
end



if __FILE__ == $0
  require 'demo_common'
  
  STYLE=Rwt::STYLE
  
  Examples = ["ShiftBox example","TabBook Example"]
  
  def example1 document
    root,window = base(document,1)
    
    par = root.find(:test)[0]
    
    r=Rwt::Container.new(par,:size=>[300,300],:style=>STYLE::BORDER_ROUND)
    
    r.add c=Rwt::ShiftBox.new(r)
    
    for i in 0..15;
      c.add o=Rwt::Drawable.new(c.inner,:size=>[-1,20],:style=>STYLE::BORDER_ROUND)
      o.style.minWidth = '50px'
      o.innerText = "foo #{i}";
    end
    
    r.show
  end
  
  def example2 document
    root,window = base(document,2)
    
    par = root.find(:test)[0]
    
    r=Rwt::TabBook.new(par,:size=>[300,300],:style=>0)
    
    for i in 0..15; pg=r.add "foo #{i}"; pg.innerText="page #{i}" end
    
    r.show
  end  
  
  launch
end
