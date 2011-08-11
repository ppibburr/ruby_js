module JS
  class Value < JS::Lib::Value

    class << self
      alias :real_new :new
    end  
      
    def self.new *o
      if o[0].is_a? Hash and o[0][:pointer] and o.length == 1
        real_new o[0][:pointer]
      else
        return JS::Value.make_undefined(*o)
      end
    end
      

  attr_accessor :context
  
  def self.from_pointer_with_context(ctx,ptr)
    res = self.new(:pointer=>ptr)
    res.context = ctx
    res
  end
    

    def self.make_undefined(ctx)
      res = super(ctx)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    def self.make_null(ctx)
      res = super(ctx)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    def self.make_boolean(ctx,boolean)
      res = super(ctx,boolean)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    def self.make_number(ctx,number)
      res = super(ctx,number)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    def self.make_string(ctx,string)
      string = JS::String.create_with_utf8cstring(string)
      res = super(ctx,string)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    def get_type()
      res = super(context,self)
      return res
    end

    def is_undefined()
      res = super(context,self)
      return res
    end

    def is_null()
      res = super(context,self)
      return res
    end

    def is_boolean()
      res = super(context,self)
      return res
    end

    def is_number()
      res = super(context,self)
      return res
    end

    def is_string()
      res = super(context,self)
      return res
    end

    def is_object()
      res = super(context,self)
      return res
    end

    def is_object_of_class(jsClass)
      res = super(context,self,jsClass)
      return res
    end

    def is_equal(b,exception = nil)
      b = JS::Value.from_ruby(context,b)
      res = super(context,self,b,exception)
      return res
    end

    def is_strict_equal(b)
      b = JS::Value.from_ruby(context,b)
      res = super(context,self,b)
      return res
    end

    def is_instance_of_constructor(constructor,exception = nil)
      constructor = JS::Object.from_ruby(context,constructor)
      res = super(context,self,constructor,exception)
      return res
    end

    def to_boolean()
      res = super(context,self)
      return res
    end

    def to_number(exception = nil)
      res = super(context,self,exception)
      return res
    end

    def to_string_copy(exception = nil)
      res = super(context,self,exception)
      return JS.read_string(res)
    end

    def to_object(exception = nil)
      res = super(context,self,exception)
      return check_use(res) || JS::Object.from_pointer_with_context(context,res)
    end

    def protect()
      res = super(context,self)
      return res
    end

    def unprotect()
      res = super(context,self)
      return res
    end
  end
end
