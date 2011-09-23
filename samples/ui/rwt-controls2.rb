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
    def initialize par,value='',*o
      if !value.is_a?(String)
        o.insert(0,value)
        value = ''
      end
    
      super par,*o 
       
      {
        'font-family'      => 'Helvetica, sans-serif',
        'font-size'        => '12px',
        'line-height'      => '14px',
        'background-color' => '#ffffFF',
        'margin'=>'1px',
        'white-space' => 'nowrap'
      }.each_pair do |k,v|
        style[k.to_s] = v
      end
      
      self.contentEditable=true
      
      self.innerHTML=value.gsub("\n","<br>").gsub(" ","&nbsp;")
    end
    
    def color c=nil
      style.color = c if c
      return style.color
    end
    
    def bgcolor c=nil
      style['background-color']=c if c
      return style['background-color']
    end
    
    def replace match,new
      self.innerText = self.innerText.gsub(match,new)
    end
    
    def char_at idx
      innerText[idx..idx]
    end
    
    def word_at idx
      [
        before(idx).split(" ").last,
        after(idx).split(" ").first
      ].join
    end
    
    def after idx
      split_at(idx).last
    end
    
    def before idx
      split_at(idx).first
    end
    
    def split_at idx
      [innerText[0..idx],innerText[idx+1..innerText.length-1]]
    end
    
    def self.included q
      q.class_eval do
        def self.default_style
          STYLE::BORDER_ROUND|STYLE::SUNKEN|super
        end         
      end
    end
    
    [:split,:reverse,:downcase,:upcase,:capitalize,:strip,:swapcase,:lines,:length].each do |k|
      define_method(k) do |*o,&b|
        self.textContent = textContent.send k,*o,&b
      end
    end
  end
  
  class TextView < Drawable
    include Text
    def initialize *o
      o = default_opts(o,:tag=>'pre')
      super *o
      extend UI::Scrollable
    end
  end
  
  class Entry < Drawable
    include Text
    def initialize par,*o
         
      o=default_opts(o,:size=>[-1,20])

      super par,*o
      
      style.overflow='hidden'
    end
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
    
    r=Rwt::VBox.new(root.find(:test)[0],:size=>[300,300],:style=>STYLE::FIXED|STYLE::CENTER)
    
    r.add tv=Rwt::TextView.new(r,File.read(__FILE__),:style=>STYLE::DEFAULT),1,true
  #  tv.replace(/def/,"fire")
  #  tv.reverse
    
    r.add e=Rwt::Entry.new(r,'dummy _value',:style=>STYLE::DEFAULT),0,1
    
    r.show
  #  window.alert(tv.word_at(500))
  puts tv.textContent
  end  
  
  launch
end
