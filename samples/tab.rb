module Rwt
  class Tabbed < Drawable
  attr_accessor :children
    def initialize par,*o
      super
      @children = []
      Collection.new(self,[self]).add_class("tabs")
    end
    
    def add l
      label = Rwt::Object.new(self,'div')
      ll=Rwt::Object.new(label,'a')
      ll.element.innerText=l
      ll.element.href="##{ll.object_id}"
      page = Page.new(label,:size=>[-5,-40],:position=>[0,20])
      @children << [label,page]
      page.id = "#{ll.object_id}"
      label.style.top = "5px"
      page
    end
    
    def show
      super
      @children.each do |a|
        a[1].show
      end
    end
    
    class Page < Bin
      def initialize par,*o
        super 
        Collection.new(self,[self]).add_class("tab_page")       
      end
      def show
        super(nil)
        return if !child
        child.size[0] = -5
        child.size[1] = -5        
        child.show
      end
    end
  end
end
