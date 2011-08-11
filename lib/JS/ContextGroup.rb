module JS
  class ContextGroup < JS::Lib::ContextGroup

    class << self
      alias :real_new :new
    end  
      
    def self.new *o
      if o[0].is_a? Hash and o[0][:pointer] and o.length == 1
        real_new o[0][:pointer]
      else
        return JS::ContextGroup.create(*o)
      end
    end
      

    def self.create()
      res = super()
      wrap = self.new(:pointer=>res)
      return wrap
    end

    def retain()
      res = super(self)
    end
  end
end
