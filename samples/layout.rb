class Layout
  X_MAJOR = 0
  Y_MAJOR = 1
  attr_reader :minor,:major
  def initialize object,min=0,maj=0
    @minor=min
    @major=maj
    @object=object
  end
  
  def layout
    if omaj=object.parent.respond_to?(:major_axis)
      if omaj <=> 1 < 0
        fill_x
        fill_y if minor > 0
      else
        fill_y
        fill_x if minor > 0
      end
      return
    end
    
    
  end
  
  def fill_x
    object.style.width = 'auto'
  end
  
  def fill_y
    object.style.height = 'auto'
  end
end
    
