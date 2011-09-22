

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
        'background-color' => '#CCCCFF'
      }.each_pair do |k,v|
        style[k.to_s] = v
      end
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
