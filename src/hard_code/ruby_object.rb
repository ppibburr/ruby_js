class JS::RubyObject < JS::Object
  class << self
    alias :ro_new :new
  end
  
  def self.new(ctx)
    res = ro_new(:pointer=>JS::Lib::JSObjectMake(ctx,CLASS,nil))
    res.context = ctx
    PTRS[res.pointer.address]=res
    res
  end
end



class JS::RubyObject
  PTRS = {}
  CLASS_DEF = JS::Lib::JSClassDefinition.new
  
  CLASS_DEF[:getProperty] = proc do |ctx,obj,name,err|
    if (n=JS.read_string(name,false)) == "object_get_property"
      nil
    else
      o=PTRS[obj.address]
      o.object = File
      o.object_get_property(n)
    end
  end
  
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
    o=JS::Object.new(context) do |this,*o|
      m.call(*o)
    end
    v = JS::Value.from_ruby(context,o).to_ptr
  end
end
