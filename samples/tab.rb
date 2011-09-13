module Rwt
  class Tabbed < VBox
    CSS_CLASS = "tabbed"
    attr_reader :tab_bar,:active
    def initialize(par,*o)
      super
      
      Collection.new(self,[self]).add_class('tabbed')
      @tab_bar = TabBar.new(self)
      add! @tab_bar,0,1
    end
    
    alias :'add!' :add
    def add l="..."
      add!(page = Page.new(self),1,1)
      @tab_bar.add l=PageLabel.new(@tab_bar,page,l)
      page.label = l
      children.last.hide
      page
    end
    
    def set_active pg
      @tab_bar.set_active(pg.label)
      if @active != pg
        @active.hide if @active
      end
      @active = pg 
      pg.show if !pg.shown
      pg
    end
    
    def show
      super
      @active ||= set_active page(0)
      hide_inactive
    end
    
    def hide_inactive
      children.each_with_index do |c,i|
        if i > 0
          c.hide if c!=@active
        end
      end    
    end
    
    def pages
      children[1..children.length-1]
    end
    
    def page i
      pages[i]
    end
    
    class Page < Rwt::Bin
      CSS_CLASS = "tab_page"
      include Rwt::Resizer
      attr_accessor :label
      def initialize *o
        super
        Collection.new(self,[self]).add_class('tab_page')
        collection!.bind(:resize) do |this,cw,ch|
          size[0] = element.clientWidth.to_f
          size[1] = element.clientHeight.to_f
          if child.resizable
            child.resize_to *[size[0]-15,size[1]-15]
            p size
            p child.size
          end        
        end
      end
      def show
        super
        p child.size
      end
    end
    
    class PageLabel < Rwt::Object
      CSS_CLASS = "tab_label"
      attr_accessor :page
      def initialize par,pg,l,*o
        super par.inner,'span'
        @page = pg
        element.innerText=l
 
        Collection.new(self,[self]).add_class("tab_label").bind(:click) do
          @page.parent.set_active(@page)
        end
        
        collection!.add_class("label")
        
        @class_name = self.className        
        style.position = 'relative'
      end
      
      def show
        self.className= @class_name
        @shown = true
      end
      
      def hide
        self.className= "hidden"
        @shown = false
      end
    end
    
    class TabBar < HBox
      CSS_CLASS = "tab_bar"
      attr_accessor :inner
      def initialize par,*o
        super
        
        add! @left=Label.new(self,'<<',:size=>Rwt::Size.get_size(:tab_shift)),1
        add! i = Container.new(self,:size=>Rwt::Size.get_size(:tab_bar_inner)),2
        add! @right=Label.new(self,">>",:size=>Rwt::Size.get_size(:tab_shift)),1     
        @inner = i
        Collection.new(self,[self]).add_class("tab_bar")
        
        Collection.new(self,[@right]).bind(:click) do
          shift_right
        end
        
        Collection.new(self,[@left]).bind(:click) do
          shift_left
        end        
        
        Collection.new(self,[@inner]).add_class("tab_bar_inner")
        
        Collection.new(self,[@right,@left]).add_class("tab_shift") 
        
        @shift_position = 0
      end
      
      def set_active l
        Collection.new(@inner,@inner.children).remove_class("tab_label_active")
        Collection.new(@inner,[l]).add_class('tab_label_active')
        l
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
        @shift_position = @shift_position - 1
        @inner.children[@shift_position].show
        hide_not_displayed    
      end
      
      def hide_not_displayed
        a=@inner.children.find_all do |c| 
          x,y = findPos(c.parent.element)
          (c.element.offsetTop+y) > (findPos(@right.parent.element)[1]+@right.element.offsetTop+1)
        end.map do |c|
          c.hide
        end
        
        if @inner.children.index(@inner.children.find do |c| !c.shown end) == 0
          @left.show  
        else
          @left.hide if @left.shown
        end
        
        if !@inner.children.last.shown
          @right.show
        else
          @right.hide if @right.shown
        end
      end
            
      alias :'add!' :add
      def add pl
        @inner.add pl
      end
      def show
        super
        hide_not_displayed
      end
    end
  end
end
