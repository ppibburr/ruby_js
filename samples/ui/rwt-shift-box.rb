if __FILE__ == $0
  require 'rwt2'
else

module Rwt
  class ShiftBox < HBox
    attr_accessor :right_expander,:left_expander,:inner
    def initialize *o
      super
      
      add! @left_expander = l = Rwt::Drawable.new(self,:size=>[30,20])
      add! @inner = Rwt::HBox.new(self,:size=>[-1,20]),1
      add! @right_expander = r = Rwt::Drawable.new(self,:size=>[30,20])

      l.innerText = ' << '
      r.innerText= " >> "

      @_child_parent = @inner

      r.on('click',method(:step_right))
      
      l.on('click',method(:step_left))

      @_offset = 0
    end
    
    def step_left *o
      if inner.children[1].shown and @left_expander.shown
        @left_expander.hide
        #show false,false,true
      end

      if !@right_expander.shown
        @right_expander.show
       # show false,true,true
      end
      
      return if inner.children[0].shown
      
      inner.children.reverse[@_offset+1].hide
      c=inner.children.find() do |c| c.shown end
      if c
        idx = inner.children.index(c) - 1
        p [:idx,idx]
        inner.children[idx].show if idx >= 0
      end
      @_offset += 1
    end
    
    def step_right *o
      if @_offset == 1 and @right_expander.shown
        @right_expander.hide
        #show false,true,false;
      end
      
      return if @_offset == 0
      
      if !@left_expander.shown
        @left_expander.show
        #show false,true,(@right_expander.shown ? true : false)
      end
      
      inner.children.reverse[@_offset].show
      @_offset -= 1
    
      if ch=inner.children.find() do |c| c.shown end
        ch.hide
      end
    end
  
    def show
      super
    end
    
    def show c=true,l=false,r=false
      super()
      [@right_expander,@left_expander].map do |c| style.cursor='pointer' end
      @right_expander.hide if !r
      @left_expander.hide if !l
      return unless c
      bs = 0
      
      inner.children.each do |c|
        bs += c.get_size.width
      end
      p [:bs,bs];ox = get_size.width-@right_expander.get_size.width-@left_expander.get_size.width
      if bs > ox
        rev = inner.children.reverse
        cnt = 0
        p [:here]
        until bs <= ox
          ts=rev[cnt].get_size.width
          rev[cnt].hide
          cnt += 1
          bs -= ts
        end
        
        if cnt > 0
          if !@right_expander.shown
            @right_expander.show
            show false,false,true
          end
        end
        
        @_offset = cnt
      end
    end
    
    def show_expander(orient=:right)
      raise ArgumentError.new("expect symbol or string of 'right' or 'left'") unless [:left,:right].index(orient.to_sym)
      send("#{orient}_expander").show
    end
    unless method_defined?(:add1)
    alias :'add!' :add  
    else
    exit
    end
    def add o      
      inner.add o,1
  
      return o
    end
  end
end
end


if __FILE__ == $0
  require 'demo_common'
  
  STYLE=Rwt::STYLE
  
  Examples = ["ShiftBox example"]
  
  def example1 document
    root,window = base(document,1)
    
    par = root.find(:test)[0]
    
    r=Rwt::Container.new(par,:size=>[300,300],:style=>STYLE::BORDER_ROUND)
    
    r.add c=Rwt::ShiftBox.new(r)
    
    for i in 0..15;
      c.add o=Rwt::Drawable.new(c.inner,:size=>[-1,20],:style=>STYLE::BORDER_ROUND)
      o.style.minWidth = '50px'
      o.innerText = "foo #{i}";
    end
    
    r.show
  end
  
  launch
end
