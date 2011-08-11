class Function
  class Param
    attr_accessor :name,:c_type
    def initialize name,type
      @name = name
      @c_type = type
    end
  end
  
  class Return
    attr_accessor :c_type
    def initialize type
      @c_type = type
    end
  end
  
  attr_accessor :result,:name,:params
  def initialize name
    @name = name
    @params = []
  end
  
  def add_parameter prm
    @params << prm
  end
end

class Constructor < Function
end
