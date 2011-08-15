class JS::Value
  def to_ruby

    if is_null
      nil
    elsif is_undefined
      :undefined
    elsif is_number
      to_number
    elsif is_string
      to_string_copy
    elsif is_object
      to_object
    elsif is_boolean
      to_boolean
      else
      
      raise "#{pointer.address} is of type #{get_type}"
    end 
  end
  
  def self.from_ruby ctx,rv = :undefined,&b
    if rv.is_a?(JS::Lib::Value)
      rv
    else
      if rv.is_a?(String);
        s = rv
        make_string(ctx,s)
      elsif rv.is_a?(Integer)
        make_number(ctx,rv)
      elsif rv.is_a?(Float)
        make_number(ctx,rv)
      elsif rv == true || rv == false
        make_boolean(ctx,rv)
      elsif rv == nil and !b
        make_null ctx
      elsif rv.is_a?(JS::Lib::Object)
        res = JS.execute_script(ctx,"this;",rv)
      elsif rv == :undefined
        make_undefined ctx
      elsif rv.is_a?(Hash) || rv.is_a?(Array)
        from_ruby(ctx,JS::Object.from_ruby(ctx,rv))
      elsif rv.is_a?(Method) || b || rv.is_a?(Proc)
        from_ruby(ctx,JS::Object.from_ruby(ctx,rv,&b))
      else
        raise "cant make value from #{rv.class}."
      end
    end
  end
end

def JS.read_string(str)
  str = JS::String.new(:pointer=>str)
  size = str.get_length
  str.get_utf8cstring a=FFI::MemoryPointer.new(:pointer,size+1),size+1
  str.release
  a.read_string()
rescue ArgumentError => e
  puts "FIX ** WARNING ** FIX"
  puts "  change :string type to :pointer in ffi function :JSStringGetUTF8CString"
  raise e
end

class JS::Object
  class << self
    alias :non_ruby_new :new
  end
  
  def self.new *o,&b
    if o.length == 2 or (o.length == 1 && (!o[0].is_a?(Hash) || !o[0].has_key?(:pointer)))
      from_ruby *o,&b
    else
      non_ruby_new *o
    end
  end
  
  def self.from_ruby ctx,rv=nil,&b
    res = nil
    if !rv and !b
      res = self.make(ctx)
    elsif rv.is_a?(JS::Lib::Object)
      return rv
    elsif rv.is_a?(Hash)
      res = self.new ctx
      res.context = ctx
      rv.each_pair do |prop,v|
        res[prop.to_s] = v
      end
    elsif rv.is_a?(Array)
      res = self.make_array(ctx,rv.length,JS.rb_ary2jsvalueref_ary(ctx,rv))
    elsif rv.is_a?(Method)
      res = self.make_function_with_callback ctx,'' do |*o|
        rv.call(*o)
      end
    elsif rv.is_a?(Proc)
      res = self.make_function_with_callback ctx,'', &rv
    elsif b;
      res = self.make_function_with_callback ctx,'',&b
    else
      return nil
    end
    res.context = ctx || context
    return res
  end
  
  def [] k
    if k.is_a?(Integer)
      prop = get_property_at_index(k)
    else
      prop = get_property(k)
    end
    
    if prop.is_a?(JS::Object) && prop.is_function
      class << prop
        attr_accessor :this
      end
      prop.this = self
    end
    prop
  end
  
  def []= k,v
    set_property(k,v)
  end
  
  def properties
    ary = []
    for i in 1..copy_property_names.get_count
      ary << copy_property_names.get_name_at_index(i-1)
    end
    ary
  end
  
  def functions
    ary = []
    properties.each do |prop|
      ary << prop if self[prop].is_a?(JS::Object) and self[prop].is_function
    end
    ary
  end
  
  def call *args
    raise('Can not call JS::Object (JS::Object#=>is_function returned false') if !is_function
    @this ||= nil
    call_as_function @this,args.length,JS.rb_ary2jsvalueref_ary(context,args)
  end
end


class JS::CallBack < Proc
  class << self
    alias :real_new :new
  end
  
  def self.new block
    real_new do |*o|
      ctx,function,this = o[0..2]
      varargs = []
      o[4].read_array_of_pointer(o[3]).each do |ptr|
        varargs <<  JS::Value.from_pointer_with_context(ctx,ptr)
      end
      
      JS::Value.from_ruby(ctx,block.call(this,*varargs.map do |v| v.to_ruby end)).pointer
    end
  end
end

module JS
  def self.rb_ary2jsvalueref_ary(ctx,ary)
    vary = ary.map do |v| JS::Value.from_ruby(ctx,v) end
    jv_ary = FFI::MemoryPointer.new(:pointer,8)
    jv_ary.write_array_of_pointer(vary)
    jv_ary  
  end

  def self.execute_script(ctx,str,this=nil)
    str_ref = JS::String.create_with_utf8cstring(str)
    val = JS::Lib.JSEvaluateScript(ctx,str_ref,this,nil,1,nil)
    str_ref.release
    JS::Value.from_pointer_with_context(ctx,val).to_ruby
  end
  
  def self.param_needs_context? a
    a.is_a?(Array) || a.is_a?(Hash) or a.is_a?(Method) or a.is_a?(Proc)
  end
end
