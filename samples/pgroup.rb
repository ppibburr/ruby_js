module Rwt
  class PanelGroup < VBox
    def add l,bool=true
      @panels ||= {}
      pn=Panel.new(self,l,:size=>[1,1])
      add! pn,0,1
      @panels[pn]=bool
      pn.style.position='relative'
      pn.add VBox.new(pn)
      class << pn
        alias :'add!' :add
        def parent?
          @inner.children[0]||super
        end
        def add o
          @inner.child.add o,1,1
        end
        def toggle
          super
          parent.element.onchildToggled
        end
      end
      pn
    end
    
    def initialize *o
      super
      collection!.bind(:childToggled) do
        on_panel_toggle
      end
    end
    
    def on_panel_toggle
      shaded = @panels.find_all do |c| c[0].is_a?(Panel) and c[0].shaded and c[1] end
      return if shaded.length == @panels.length
      sub = 0
      children.find_all do |c| !c.is_a?(Panel) end.each do |c|
        sub = sub + c.element.clientHeight
      end
      
      @panels.find_all do |k,v|
        !v
      end.each do |k,v|
        sub=sub+k.element.clientHeight+5
      end
      
      if !shaded.empty?
        amt = (element.clientHeight - (shaded.length * shaded[0][0].size[1])) / (@panels.find_all do |k,v| v end.length - shaded.length)
        amt = amt-sub
      else
        amt = element.clientHeight - sub
        amt=amt/@panels.find_all do |k,v| v end.length        
      end  

      @panels.find_all do |c| !c[0].shaded end.each do |c|
        if c[1]
          c[0].size[1] = amt
        end
        c[0].show;c[0].element.onresize nil,0,0
      end
    end
    
    def show
      super
      on_panel_toggle
    end
  end
end
