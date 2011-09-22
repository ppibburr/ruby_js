if __FILE__ == $0
  require 'rwt2'
end

module Rwt
  class Button < Container
    def initialize parent,text='',*o
      if o.last.is_a?(Hash)
        if o.last[:style]
          o.last[:style] = o.last[:style]|STYLE::FLAT
        else
          o.last[:style] = STYLE::FLAT
        end
      else
        o << {:style=>STYLE::FLAT}
      end
      
      super parent,*o
    
      style.overflow='hidden'
      @_display = style.display='-webkit-box'
      style['-webkit-box-orient']='horizontal';
      style['-webkit-box-pack']='center'
      style['-webkit-box-align']='center'      
      style['font-family']="arial,helvetica,sans-serif"
      style['font-size']='11px'
      add @_label=Rwt::Drawable.new(self,:tag=>"p")
      @_label.set_style 0
      @_label.innerText=text

      style['min-width']='50px'
      
      @_border.round 10
      @_shadow.inset
      
      style.padding = "2px"

      collection.on("mouseover") do
        @_bgc = style['background-color']
        style['background-color']="eeefff"
      end
      
      collection.on("mouseout") do
        style['background-color']="#{@_bgc}"  
      end      
    end
    
    def click &b
      if b
        collection.on('click',&b)
      else
        collection.fire('click')
      end
    end
  end
end

if __FILE__ == $0
  require 'demo_common'
  
  STYLE = Rwt::STYLE
  
  Examples = ["Button demo","Packing understanding ..."]
  
  def example1 document;
    root,window = base document,1
    
    b=Rwt::Button.new(root.find(:test)[0],"Click Me!",:size=>[200,20],:style=>STYLE::FIXED|STYLE::CENTER)
    
    b.click do
      window.alert("Click Event")
    end
    
    b.show
  end
 
  def example2 document;
    root,window = base document,2
    
    r=Rwt::VBox.new(root.find(:test)[0],:size=>[200,250],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::FLAT)
    r.add c=Rwt::Container.new(r),1,true
   
    c.style.border="2px solid red"
    c.add h=Rwt::HBox.new(c)
   
    h.style.border = "2px solid blue"
    h.add c2=Rwt::Container.new(h),1,1

    c2.style.border="2px dashed black"
    c2.add b=Rwt::Button.new(c2,"Click Me!",:size=>[50,20],:style=>STYLE::CENTER)

    b.click do
      window.alert("Click Event")
    end  

    h.add c3=Rwt::Container.new(h),1,1
    c3.add b=Rwt::Button.new(c3,"Click Me!",:size=>[50,20],:style=>STYLE::CENTER)     
    c3.style.border="2px dashed green"    
    
    b.click do
      window.alert("Click Event")
    end    
  
    r.add c=Rwt::Container.new(r),1,true
   
    c.style.border="2px solid red"
    c.add h=Rwt::HBox.new(c)
   
    h.style.border = "2px solid blue"
    h.add c2=Rwt::Container.new(h),1,1

    c2.style.border="2px dashed black"
    c2.add b=Rwt::Button.new(c2,"Click Me!",:size=>[50,20],:style=>STYLE::CENTER|STYLE::ABSOLUTE)

    b.click do
      window.alert("Click Event")
    end  

    h.add c3=Rwt::Container.new(h),1,1
    c3.add b=Rwt::Button.new(c3,"Click Me!",:size=>[50,20],:style=>STYLE::CENTER)     
    c3.style.border="2px dashed green"    
    
    b.click do
      window.alert("Click Event")
    end     
    
    r.show
  end 
  
  launch
end
