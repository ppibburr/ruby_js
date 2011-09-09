module Rwt;end
class Rwt::FlexLayout
  X_MAJOR = 0
  Y_MAJOR = 1
  attr_reader :object,:minor,:major
  def initialize object,maj=0,min=0
    @minor=min
    @major=maj
    @object=object
  end
  
  def layout
    q=nil
    if omaj=object.parent.respond_to?(:major_axis)
      if object.parent.major_axis < 1
        fill_x if major > 0
        fill_y if minor > 0
        q = :Width
      else
        fill_y if major > 0
        fill_x if minor > 0
        q = :Height
      end
    end
  end
  
  def fill_x
    object.style.width = 'auto'
  end
  
  def fill_y
    object.style.height = 'auto'
  end
end
    
