module Rwt
  class Canvas < Drawable
    attr_reader :context
    def initialize par,*o
      o[0] ||= {}
      raise unless o[0].is_a? Hash

      super par,*o
    end
    def show 
      super
      return if @init   
      @init = true
      element.innerHTML="<canvas class=canvas id=\"cv#{id.to_s(16)}\" width=#{size[0]+15} height=#{size[1]}></canvas>"
      @object = Rwt::Collection.new(self.ownerDocument).find(:"cv#{id.to_s(16)}")[0]
      @context = @object.getContext('2d')
      context.functions.each do |f|
        class << self; self;end.instance_exec do
          define_method f do |*o|
            cxt[f].call *o
          end
        end
      end
      
    end
    
    def plot x,y,style
      cxt['fillStyle']=style;
      beginPath();
      arc(x,y,4,0,Math::PI*2,true);
      closePath();
      fill();  
    end
    
    def draw_line x,y,x1,y1
      return unless @init
      moveTo x+10.5,y+10.5
      lineTo x1+10.5,y1+10.5
      stroke
    end
    
    def cxt
      @context
    end
  end  
end
