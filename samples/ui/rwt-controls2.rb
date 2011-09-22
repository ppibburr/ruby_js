if __FILE__ == $0
  require 'rwt2'
end

module Rwt
  class ScrollView < Container
    def initialize *o
      super
      extend UI::Scrollable
    end
  end
  
  module Text
    def initialize *o
      super
      {
        'font-family'      => 'Helvetica, sans-serif',
        'font-size'        => '10px',
        'line-height'      => '12px',
        :padding           => '5px',
        'background-color' => '#ffffFF'
      }.each_pair do |k,v|
        style[k.to_s] = v
      end
    end
    
    def color c=nil
      style.color = c if c
      return style.color
    end
    
    def bgcolor c=nil
      style['background-color']=c if c
      return style['background-color']
    end
  end
  
  class TextView < Drawable
    include Text
    def initialize *o
      super
      extend UI::Scrollable
    end
  end
  
  class Entry < Drawable
    include Text
  end
end

if __FILE__ == $0
  require 'demo_common'
  
  STYLE = Rwt::STYLE 
  
  Examples = [
    "Scolled text area"
  ]
  
  
  def example1 document
    root ,window = base(document,1)
    
    r=Rwt::TextView.new(root.find(:test)[0],:size=>[300,300],:style=>STYLE::FIXED|STYLE::CENTER|STYLE::BORDER_ROUND|STYLE::FLAT)
    r.innerText=File.read(__FILE__)
    r.color "#cecece"
    r.bgcolor "#666"
    r.show
  end  
  
  launch
end
