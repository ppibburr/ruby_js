if __FILE__ == $0
  require 'rwt2'
end

module Rwt
  class Button < VBox
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
    
      add Rwt::Drawable.new(self,:size=>[1,1]),1,1
    
      @_label = Rwt::Drawable.new(self,:size=>[1,20])
      @_label.style['text-align'] = 'center'
      @_label.style['vertical-align']='middle'
      
      @_label.style['font-family']="arial,helvetica,sans-serif"
      @_label.style['font-size']='11px'
      @_label.innerText=text
      
      add @_label,0,1
      add Rwt::Drawable.new(self,:size=>[1,1]),1,1
      
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
  
  Examples = ["Button demo"]
  
  def example1 document;
    root,window = base document,1
    
    b=Rwt::Button.new(root.find(:test)[0],"Click Me!",:size=>[200,20],:style=>STYLE::FIXED|STYLE::CENTER)
    
    b.click do
      window.alert("Click Event")
    end
    
    b.show
  end
  
  launch
end
