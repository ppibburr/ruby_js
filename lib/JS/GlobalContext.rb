module JS
  class GlobalContext < JS::Lib::GlobalContext
    include JS::Context

    class << self
      alias :real_new :new
    end  
      
    def self.new *o
      if o[0].is_a? Hash and o[0][:pointer] and o.length == 1
        real_new o[0][:pointer]
      else
        return JS::GlobalContext.create(*o)
      end
    end
      

    def self.create(globalObjectClass)
      res = super(globalObjectClass)
      wrap = self.new(:pointer=>res)
      return wrap
    end

    def self.create_in_group(group,globalObjectClass)
      res = super(group,globalObjectClass)
      wrap = self.new(:pointer=>res)
      return wrap
    end

    def retain()
      res = super(self)
    end

    def release()
      res = super(self)
      return res
    end
  end
end
