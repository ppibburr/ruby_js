if __FILE__ == $0
  require 'rwt2'
else

module Rwt 
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
    
    def show
      super
      style['border-bottom-left-radius']='' 
      style['border-bottom-right-radius']=''    
    end
    
    def on_activate *o
      page.book.set_active page
      style['border-bottom'] = ''
      page.book.pages.map do |pg| pg.label end.each do |l|
        l.style['border-bottom']='1px solid black' unless l == self             
      end
    end
  end
  
  class TabBox < ShiftBox
    def initialize *o
      super
      @left_expander.style['border-bottom'] = '1px solid black'      
      @right_expander.style['border-bottom'] = '1px solid black'  
    end
  
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
    unless method_defined?(:add1)
    alias :'add!' :add  
    end
    def add l
      add! o = Book::Page.new(self,control,l,:style=>STYLE::DEFAULT|STYLE::BORDER_ROUND_BOTTOM),1,true
      
      return o
    end
  end
end
end

if __FILE__ == $0
  require 'demo_common'
  
  STYLE=Rwt::STYLE
  
  Examples = ["TabBook Example"]
  
  def example1 document
    root,window = base(document,1)
    
    par = root.find(:test)[0]
    
    r=Rwt::TabBook.new(par,:size=>[300,300],:style=>0)
    
    for i in 0..15; pg=r.add "foo #{i}"; pg.innerText="page #{i}" end
    
    r.show
  end  
  
  launch
end
