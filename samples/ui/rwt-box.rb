if __FILE__ == $0
  require 'rwt2'
end

module Rwt
  class Box < Container
    def initialize *o
      super
      style['display']='-webkit-box'
      @_display = '-webkit-box'
  #    set_style get_style&~STYLE::TAKE_WIDTH
   #   set_style get_style&~STYLE::TAKE_HEIGHT    
     # style['height']='100%'  
    end
    
    # FIXME: current implementation requires explicitly constructing the child or setting the size of the child to a size of
    #        > 0, for any axis that expansion takes place on, so the default -1 does not work
    # TODO: set childs size at Box#->add for dimnsions determined to be expandable
    def add o,major=0
      super(o)
      #o.style.minHeight='0px'
      o.style['-webkit-box-flex']=major
      o.style['-webkit-box-sizing']= 'border-box'     
    end
  end
  
  class VBox < Box
    def initialize *o
      super
      style['-webkit-box-orient']='vertical'
    end
    
    def add o,major=0,minor=nil
      super o,major
      if major > 0
        o.set_style o.get_style&~STYLE::TAKE_HEIGHT 
        o.style['height']='1'
      end
      
      if minor
        o.set_style o.get_style&~STYLE::TAKE_WIDTH
        o.style['width']='100%'
      end
    end
  end
  
  class HBox < Box
    def initialize *o
      super
      style['-webkit-box-orient']='horizontal'
    end 
    
    def add o,major=0,minor=nil
      super o,major
      if major > 0
        o.set_style o.get_style&~STYLE::TAKE_WIDTH
        o.style['width']='1'
      end
      
      if minor
        o.set_style o.get_style&~STYLE::TAKE_HEIGHT
        o.style['height']='auto'
      end
    end     
  end
end



if __FILE__ == $0
  require 'demo_common'

  STYLE = Rwt::STYLE

  Examples=[
    "Vertical box layout",
    "Horizontal",
    "Both"
  ]

  def example1 document
    root,window = base(document,1)  

    r=Rwt::VBox.new(root.find(:test)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::FIXED|STYLE::BORDER_ROUND_LEFT|STYLE::FLAT) 

    r.add c=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),1,true  
    r.add c1=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),2,true
    r.add c2=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),3,true

    r.show
  end

  def example2 document
    root,window = base(document,2)  
    r=Rwt::HBox.new(root.find(:test)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::FIXED|STYLE::BORDER_ROUND_LEFT|STYLE::FLAT) 

    r.add c=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),1,true  
    r.add c1=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),2,true
    r.add c2=Rwt::Drawable.new(r,:style=>STYLE::BORDER_ROUND),3,true

    r.show
  end 

  def example3 document
    root,window = base(document,3)  

    r=Rwt::VBox.new(root.find(:test)[0],:size=>[500,500],:style=>STYLE::CENTER|STYLE::FIXED|STYLE::BORDER_ROUND_LEFT|STYLE::FLAT) 

    hba=[]
    maj=[1,2,3]

    for i in 0..2
      r.add hb=Rwt::HBox.new(r),maj[i],true
      hba << hb
    end

    hba.each do |c|
      for i in 0..2
        c.add Rwt::Drawable.new(c,:style=>STYLE::BORDER_ROUND|STYLE::RAISED),maj[i],true
      end
    end

    r.show
  end  

  launch
end
