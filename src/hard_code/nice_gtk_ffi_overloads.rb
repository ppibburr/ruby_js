module NiceGtk;module Overloads;class Klass
  class Function
    attr_reader :parameters,:name
    class Param
      attr_reader :value,:name,:index
      def initialize name,value,index
        @name,@value,@index = name.to_sym,value,index
      end
    end
    def initialize name
      @parameters = []
      @name = name
    end
    def add_parameter name,value,i=nil
      i = @parameters.length if !i
      @parameters << prm = Param.new(name,value,i)
      prm
    end
    def get_parameter n
      @parameters.find do |prm| prm.name == n end
    end
    def arity
      if q=parameters.find do |prm| prm.value == :vargs end
        return (parameters.index(q)+1)*-1
      end
      @parameters.find_all do |prm| prm.value==:undefined end.length
    end
    def defaults ary
      s = ary.length
      err = ArgumentError.new("Expected #{min}..#{max} arguments.")
      max = @parameters.length
      min = arity
      raise err if (ary.length > max and arity > 0) or ary.length < arity
      ary.push *(@parameters[s..@parameters.length-1].map do |prm| 
        next if prm.value == :vargs
        raise err if prm.value == :undefined
        prm.value
      end)
    end
  end
  class Construct < Function
    def initialize
      name = :new
      super(name)
    end
  end
  
  class Meth < Function
    def initialize n
      super
    end 
  end
  attr_reader :name,:construct,:methods
  def initialize n
    @name = n.to_sym
    @methods = []
    @construct = nil
  end
  def create_construct
    @construct = Construct.new()
  end
  def create_method n
    @methods << Meth.new(n)
  end
  def method n
    @methods.find do |m| m.name == n end
  end
end;end;end
