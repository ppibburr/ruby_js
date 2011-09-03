module Rwt
  class Tabbed < Container
    attr_accessor :tab_bar
    def initialize(par,*o)
      super
      
      Collection.new(self,[self]).add_class('tabby')
      @tab_bar = TabBar.new(self)
      @tab_bar.size[1] = 25
      add! @tab_bar
    end
    alias :'add!' :add
    def add l="..."
      add! page = Page.new(self,:size=>[-1,-25],:position=>[0,25])
      @tab_bar.add l=PageLabel.new(@tab_bar,page,l,:size=>[-1,24])
      page.label = l
      children.last.hide
      page
    end
    
    def show
      super(nil)
      @tab_bar.show
      children.each_with_index do |c,i|
        if i+1 < children.length and i > 0
          c.show;
          c.hide
        else
          c.show
        end
      end
      children[1].show if children[1]
    end
    
    class Page < Rwt::Scrollable
      attr_accessor :label
    end
    
    class PageLabel < Rwt::Object
      attr_accessor :page
      def initialize par,pg,l,*o
        super par.inner,'span'
        @page = pg
        pg.style['background-color']='blue'
        element.innerText=l
 
        Collection.new(self,[self]).add_class("page_label")
      end
    end
    
    class TabBar < Container
      attr_accessor :inner
      def initialize par,*o
        super
        
        add! @left=Label.new(self,'<<',:size=>[50,-1])
        add! @right=Label.new(self,">>",:size=>[50,-1])
        @inner = Container.new(self,:position=>[51,-1])
        @inner.style['background-color']='red'
        @inner.style.overflow='hidden'
        @left.style.cursor = @right.style.cursor = 'pointer'
        @right.style['text-align']='right'
        
        
        
        Collection.new(self,[@right]).bind(:click) do
          shift_right
        end
        
        Collection.new(self,[@left]).bind(:click) do
          shift_left
        end        
        
        @shift_position = 0
      end
      
      def findPos obj
		    curleft = curtop = 0;
		    if (obj.offsetParent)	
          while (obj = obj.offsetParent);
				    curleft += obj.offsetLeft;
				    curtop += obj.offsetTop;	
          end
        end
		    return [curleft,curtop];
	    end
      
      def shift_right
        return if @inner.children.last.shown
        @shift_position += 1
        @inner.children.each_with_index do |c,i|
          c.show if i >=@shift_position
        end
        @inner.children[@shift_position-1].hide
        hide_not_displayed
      end
      
      def shift_left
        return if @shift_position <= 0
        @shift_position = @shift_position - 1 unless @shift_position <= 0
        @inner.children[@shift_position-1].show
        hide_not_displayed    
      end
      
      def hide_not_displayed
        @inner.children.find_all do |c| 
          c.element.offsetTop > @right.element.offsetTop
        end.each do |c|
          c.hide
        end
      end
            
      alias :'add!' :add
      def add pl
        @inner.add pl
      end
      def show
        super(nil)
        @left.show
        @inner.size[0] = element.clientWidth.to_f-102
        @inner.show
        @right.position[0]=element.clientWidth.to_f-50
        @right.show
        hide_not_displayed
      end
    end
  end
end
