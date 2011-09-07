module Rwt
  class Object
    def collection!
      Collection.new(self,[self])
    end
  end
  class Button < Bin
    CSS_CLASS = "button"
    
    attr_reader :label  
    def initialize par,q,*o
      text = q
      if q.is_a? Hash
        o = [q]    
        text=nil    
      end
      
      super par,*o
      
      collection!.add_class CSS_CLASS
      @label = Rwt::Label.new(self,text)
      @label.style.position='static'
      add(@label)
      
      @label.collection!.bind(:click) do |*o|
        @evt_handle.call *o if @evt_handle
      end.add_class("button_label")

      @label.style['text-align']='center'
      @label.style['vertical-align']='middle'
      style['text-align']='center'
      style['vertical-align']='middle'      
    end
    
    def on_activate &b
      @evt_handle = b
    end
    
    def show
      super
      child.style.width='100%'    
    end
  end
end
