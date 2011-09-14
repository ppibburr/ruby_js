class Flags
  class Flag
    attr_reader :label,:value
    def initialize label,value
      @label,@value = label,value
    end
    
    def to_int
      value
    end
    alias :to_i :to_int
    
    def | q
      to_i|q
    end
    
    def & q
      to_i&q
    end
    
    def inspect
      to_i
    end
  end
  
  def initialize a
    q=class << self
      @last=0.5
      NONE = 0
      def self.add k
        const_set k,Flag.new(k,i=(2*@last).to_i)
        @last = i
      end
      
      def self.flags
        constants.find_all do |c| const_get(c).is_a? Flags::Flag end
      end
      
      def self.const_missing k
        if k.to_sym == :ALL
          return @last.to_s(2).gsub("0","1").to_i(2)
        end
        
        raise NameError.new("unitialized constant #{self}::#{k}")
      end
        
      self
    end
    
    a.each do |k|
      q.add k
    end
  end
  
  class << self
    alias :real_new :new
  end
  
  def self.new *o
    rt = real_new *o
    class << rt
      self
    end
  end
end

class Style
  def initialize flags,from
    @flags = flags
    @from = from
    
    q=class << self;
      def self.add_has_method(k)
        define_method "has_#{k}?".downcase do
          has_flag?(k)
        end
      end
      self;
    end
    
    flags.flags.each do |f|
      q.add_has_method f
    end
  end
  
  def has_flag?(k)
    i=(@from&@flags.const_get(k))
    bool = (i == @flags.const_get(k).to_int)
    bool
  end
end

module Rwt
  STYLE = Flags.new([
    :RESIZABLE,       # panel
    :CAN_SHADE,       # panel
    :CAN_DRAG,        # panel
    :EXPAND,          # drawable
    :GROW,            # drawable
    :CENTER,          # object
    :BORDER,          # object
    :BOX_SHADOW,      # object
    :BOX_SHADOW_INSET # object
  ])
end

if __FILE__ == $0
  STYLE=Flags.new([:FIRST,:SECOND,:THIRD,:FOURTH])
  flags = STYLE::FIRST|STYLE::FOURTH

  style=Style.new(STYLE,flags)
  p style.has_flag?(:SECOND)
  p style.has_first?
  p style.has_third?
  p style.has_fourth?

  STYLE1=Flags.new([:FIRST,:SECOND,:THIRD])
  flags = STYLE1::FIRST|STYLE1::THIRD

  style=Style.new(STYLE1,flags)
  p style.has_flag?(:SECOND)
  p style.has_first?
  p style.has_third?

  begin
    p style.has_fourth?
    raise "should not get here"
  rescue
  end

  p STYLE::FOURTH

  begin
    p STYLE1::FOURTH
    raise "should not get here"
  rescue
  end
end
