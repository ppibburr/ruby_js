if __FILE__ == $0
  p Dir.getwd
  $: << Dir.getwd
  require 'rwt2'
end

module Rwt
  module SlidePane
    def self.included q
      q.class_eval do
        alias :'add!' :add
        undef :add      
      end
    end

    def initialize *o
      super
      add! Rwt::Drawable.new(self,:size=>[0,0]),0,0
      children[0].style.minWidth=''
      children[0].style.minHeight=''
      style.overflow='hidden'
    end
  
    def add1 o
      raise if @_add1
      add! o,1,true

      @_add1 = true
      
      removeChild(children[0].element)   
      
      create_handle
      
      if @_add2
        replaceChild(o.element,children[1].element)
        appendChild(children[1].element)
        @children = [o,@handle,children[1]]
      else
        @children=[o,@handle]
      end
      
      @handle.style.minWidth="3px"
      @handle.style.minHeight="3px"
      
      init_handle
      show if @shown
      @handle.hide unless (@_add1 && @_add2) || !@handle
    end
    
    def add2 o
      raise if @_add2
      add! o,1,true
      @_add2=true
      show if @shown
      @handle.hide unless (@_add1 and @_add2) || !@handle
    end
    
    def show
      super
      @handle.hide unless (@_add1 && @_add2) || !@handle
    end  
  end

  class VSlidePane < VBox
    include SlidePane
    
    private
    def create_handle
      add! @handle=Rwt::Drawable.new(self,:size=>[1,8],:style=>STYLE::FLAT),0,true    
    end
    
    private
    def init_handle
      @handle.extend Rwt::Draggable
      
      @handle.drag = JS.execute_script(context,"""
        this.dragNative=function(g,nx,ny,cx,cy) {
          y = document.defaultView.getComputedStyle(this.previousSibling, '').getPropertyValue('height') ;

          y = parseInt(y);
          this.previousSibling.style.height = (y+cy)+'px';
          y = document.defaultView.getComputedStyle(this.nextSibling, '').getPropertyValue('height') ;

          y = parseInt(y);
          this.nextSibling.style.height = (y-cy)+'px';
          return false;
        };this.dragNative;
      """,@handle.element)
    end
  end
 
  class HSlidePane < HBox
    include SlidePane
    
    private
    def create_handle
      add! @handle=Rwt::Drawable.new(self,:size=>[8,1],:style=>STYLE::FLAT),0,true    
    end
    
    private
    def init_handle
      @handle.extend Rwt::Draggable
      
      @handle.drag = JS.execute_script(context,"""
        this.dragNative=function(g,nx,ny,cx,cy) {
          x = document.defaultView.getComputedStyle(this.previousSibling, '').getPropertyValue('width') ;

          x = parseInt(x);
          this.previousSibling.style.width = (x+cx)+'px';
          x = document.defaultView.getComputedStyle(this.nextSibling, '').getPropertyValue('width') ;

          x = parseInt(x);
          this.nextSibling.style.width = (x-cx)+'px';
          return false;
        };this.dragNative;
      """,@handle.element)
    end
  end
end

if __FILE__ == $0
  require 'demo_common'
  
  Examples = [
    "Horizontal Slide Pane",
    "Vertical Slide Pane",
    "Adding out of order and event driven adding"
  ]
  
  STYLE = Rwt::STYLE
  
  def example1 document
    root ,window = base(document,1)
    
    r=Rwt::HSlidePane.new(root.find(:test)[0],:size=>[200,300],:style=>STYLE::FIXED|STYLE::BORDER_ROUND_TOP|STYLE::FLAT|STYLE::CENTER)

    r.add1 Rwt::Button.new(r,"slide the handle i'll adjust")
    r.add2 b=Rwt::Button.new(r,'me too !') 
    p(r.children.map do |c| c.class end)
    r.show 
  end  
 
  def example2 document
    root ,window = base(document,2)
    
    r=Rwt::VSlidePane.new(root.find(:test)[0],:size=>[200,300],:style=>STYLE::FIXED|STYLE::BORDER_ROUND_TOP|STYLE::FLAT|STYLE::CENTER)

    r.add1 Rwt::Button.new(r,"slide the handle i'll adjust")
    r.add2 b=Rwt::Button.new(r,'me too !') 
    
    r.show 
  end   
  
  def example3 document
    root ,window = base(document,3)
    r=Rwt::HSlidePane.new(root.find(:test)[0],:size=>[200,300],:style=>STYLE::FIXED|STYLE::BORDER_ROUND_TOP|STYLE::FLAT|STYLE::CENTER)

    r.add2 b=Rwt::Button.new(r,"i'm add2 click to add1")
    
    b.click do
      r.add1 Rwt::Button.new(r,"i'm add1") unless r.children.length == 3 
    end
    
    r.show 
  end
 
  launch
end

