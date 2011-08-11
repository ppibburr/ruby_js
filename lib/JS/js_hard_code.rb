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
  
  def self.from_ruby ctx,rv = :undefined
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
      elsif rv == nil
        make_null ctx
      elsif rv.is_a?(JS::Lib::Object)
        res = JS.execute_script(ctx,"this;",rv)
      elsif rv == :undefined
        make_undefined ctx
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
  def self.from_ruby ctx,rv
    if rv.is_a?(JS::Lib::Object)
      rv
    elsif rv.is_a?(Hash)
      raise "not yet" # TODO
    elsif rv.is_a?(Array)
      raise "not yet"
    elsif rv.is_a?(Method)
      raise "not yet"
    elsif !rv
      nil
    end
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
end
