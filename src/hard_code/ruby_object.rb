class JS::RubyObject < JS::Object
  class << self
    alias :ro_new :new
  end
  
  def self.new(ctx,object=Object)
    res = ro_new(:pointer=>JS::Lib::JSObjectMake(ctx,CLASS,nil))
    res.context = ctx
    PTRS[res.pointer.address]=res
    res.object = object
    res
  end
end



class JS::RubyObject < JS::Object
  PTRS = {}
  PROCS = {}
  CLASS_DEF = JS::ClassDefinition.new
  
  CLASS_DEF[:getProperty] = pr = proc do |ctx,obj,name,err|
    if (n=JS.read_string(name,false)) == "object_get_property"
      nil
    else
      o=PTRS[obj.address]
      o.object_get_property(n)
    end
  end
  PROCS[pr] = true
  
  # IMPORTANT: set definition fields before creating class
  CLASS = JS::Lib.JSClassCreate(CLASS_DEF)

  attr_accessor :object
  
  def object_has_property? n
    if object.respond_to?(n)
      true
    else
      nil
    end   
  end
  
  def object_get_property n
    return nil if !object_has_property?(n)
    m=object.method(n)
    o=JS::Object.new(context) do |*o1|
      this = o1[0]
      o1.delete_at(0)
      closure = nil
      if o1.last.is_a?(JS::Object) and o1.last.is_function()
        function = o1.last
        closure = proc do |*a|
          function.context = context # FIXME: nasty find out why
          function.call(*a)
        end
        o1.delete_at(o1.length-1)
      end
      q = m.call(*o1) do |*ab|
        closure.call *ab if function
      end
      JS::Value.from_ruby(context,q)
    end

    v = JS::Value.from_ruby(context,o)#.to_ptr
    v.to_ptr
  end
end
