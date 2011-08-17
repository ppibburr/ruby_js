module JS::Lib
  attach_function :JSClassCreate,[:pointer],:pointer
end

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

module JS::RubyObject::Lib
  extend FFI::Library
  ffi_lib "#{File.join(File.dirname(__FILE__),'ffi','ext','JSRubyObjectClass.so')}"
  callback :JSObjectGetPropertyCallback,[:pointer,:pointer,:pointer,:pointer],:pointer
  callback :JSObjectSetPropertyCallback,[:pointer,:pointer,:pointer,:pointer,:pointer],:pointer
  callback :JSObjectHasPropertyCallback,[:pointer,:pointer,:pointer],:pointer
  callback :JSObjectDeletePropertyCallback,[:pointer,:pointer,:pointer,:pointer],:pointer
  attach_function :JSRubyObjectClass,[],:pointer
  attach_function :JSRubyObjectClassSetGetPropertyCallback,[:pointer,:JSObjectGetPropertyCallback],:void
  attach_function :JSRubyObjectClassSetSetPropertyCallback,[:pointer,:JSObjectSetPropertyCallback],:void
  attach_function :JSRubyObjectClassSetHasPropertyCallback,[:pointer,:JSObjectHasPropertyCallback],:void

end

class JS::RubyObject
  PTRS = {}
  CLASS_DEF = JS::RubyObject::Lib.JSRubyObjectClass

  JS::RubyObject::Lib.JSRubyObjectClassSetGetPropertyCallback(CLASS_DEF, proc do |ctx,obj,name,err|
    if (n=JS.read_string(name)) == "object_get_property"
      nil
    else
      o=PTRS[obj.address]
      o.object = File
      o.object_get_property(n)
    end
  end)
  
  JS::RubyObject::Lib.JSRubyObjectClassSetSetPropertyCallback(CLASS_DEF, proc do |ctx,obj,name,val,err|

  end)
  
  #JS::RubyObject::Lib.JSRubyObjectClassSetHasPropertyCallback(CLASS_DEF, proc do |ctx,obj,name|
    #puts "has property? #{JS.read_string name}"
  #end)
  
  #

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
    m=object.method(n)
    o=JS::Object.new(context) do |this,*o|
      m.call(*o)
    end
    v = JS::Value.from_ruby(context,o).to_ptr
  end
end
