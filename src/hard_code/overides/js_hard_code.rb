
#       js_hard_code.rb
             
#		(The MIT License)
#
#        Copyright 2011 Matt Mesanko <tulnor@linuxwaves.com>
#
#		Permission is hereby granted, free of charge, to any person obtaining
#		a copy of this software and associated documentation files (the
#		'Software'), to deal in the Software without restriction, including
#		without limitation the rights to use, copy, modify, merge, publish,
#		distribute, sublicense, and/or sell copies of the Software, and to
#		permit persons to whom the Software is furnished to do so, subject to
#		the following conditions:
#
#		The above copyright notice and this permission notice shall be
#		included in all copies or substantial portions of the Software.
#
#		THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
#		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 

class JS::Value
  class ConversionError < ArgumentError
  end
  
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
      JS::Lib.JSValueProtect(context,self)
      o=to_object
     
    elsif is_boolean
      to_boolean
    elsif nil == pointer
      nil
    else
      raise ConversionError.new("#{pointer.address} is of type #{get_type}")
    end 
  end
  
  def self.from_ruby ctx,rv = :undefined,&b
    if rv.is_a?(JS::Lib::Value)
      rv
    else
      if rv.is_a?(JS::Lib::String);
        s = rv
        JS::Lib::Value.make_string(ctx,s)
      elsif rv.is_a?(String)
        make_string(ctx,rv)
      elsif rv.is_a?(Integer)
        make_number(ctx,rv)
      elsif rv.is_a?(Float)
        make_number(ctx,rv)
      elsif rv.is_a?(JS::Lib::Object)
        res = JS.execute_script(ctx,"this;",rv)
      elsif rv.is_a?(Hash) || rv.is_a?(Array)
        from_ruby(ctx,JS::Object.new(ctx,rv))
      elsif rv.is_a?(Method) || b || rv.is_a?(Proc)
        from_ruby(ctx,JS::Object.new(ctx,rv,&b))
      elsif rv == :undefined
        make_undefined ctx
      elsif rv == true || rv == false
        make_boolean(ctx,rv)
      elsif rv == nil and !b
        make_null ctx
      #elsif rv.is_a? FFI::Pointer
       # JS::Object.from_pointer_with_context ctx,rv
      else
        #raise ConversionError.new("cant make value from #{rv.class}.")
        from_ruby(ctx,JS::RubyObject.new(ctx,rv))
      end
    end
  end
end

def JS.read_string(str,rel=true)
  str = JS::String.new(:pointer=>str)
  val = str.to_s
  str.release if rel
  return val
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
    res = nil
    if o.length == 2 or (o.length == 1 && (!o[0].is_a?(Hash) || !o[0].has_key?(:pointer)))
      res = from_ruby *o,&b
    else
      res = non_ruby_new *o
    end
    
    return res
  end
  
  def self.from_ruby ctx,rv=nil,&b
    res = nil
    if !rv and !b
      res = self.make(ctx)
    elsif rv.is_a?(JS::Lib::Object)
      return rv
    # make object with properties of hash
    elsif rv.is_a?(Hash)
      res = self.new ctx
      res.context = ctx
      rv.each_pair do |prop,v|
        res[prop.to_s] = v
      end
    # make array from ruby array
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
    res.context = ctx
    return res
  end
  def store_function n,a=nil
    a ||= n
    @stored_funcs||={}
    @stored_funcs[n] = self[n]
    class << self
      self
    end.class_eval do
      define_method a do |*o,&b|
        func = @stored_funcs[n]
        func.this = self
        func.call *o,&b
      end
    end
  end
  def [] k
    if k.is_a?(Float) and k == k.to_i
      k = k.to_i
    end
    raise unless k.is_a?(Symbol) or k.is_a?(String) or k.is_a?(Integer)
    k = k .to_s
    
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
    if k.is_a?(Float) and k == k.to_i
      k = k.to_i
    end
    
    raise unless k.is_a?(Symbol) or k.is_a?(String) or k.is_a?(Integer)
    k = k .to_s
    
    set_property(k,v)
  end
  
  def properties
    ary = []
    for i in 1..(a=copy_property_names).get_count
      ary << a.get_name_at_index(i-1)
    end
    #JS::Lib.JSPropertyNameArrayRelease(a)
    ary
  end

  def functions
    ary = []
    properties.each do |prop|
      ary << prop if self[prop].is_a?(JS::Object) and self[prop].is_function
    end
    ary
  end
  PROCS = {}
  def call *args,&b
    raise('Can not call JS::Object (JS::Object#=>is_function returned false') if !is_function
    @this ||= nil
    if b
      args << JS::Object.new(context,&b)
    end
    call_as_function @this,args.length,args
  end
  
  def self.is_array(context,obj)
    return nil if !context.is_a?(JS::Lib::GlobalContext)
    JS::OBJECT(context).prototype['toString']['call'].call(obj) == "[object Array]"
  end
  def self.is_node_list(context,obj)
    return nil if !context.is_a?(JS::Lib::GlobalContext)
    JS::OBJECT(context).prototype['toString']['call'].call(obj) == "[object NodeList]"
  end
end

module JS 
  class << self
    [:Object,:Array,:String,:RegExp].each do |t|
      define_method("#{t.to_s.upcase}") do |ctx|
        JS.execute_script(ctx,"#{t};")
      end
    end
  end
end




class JS::CallBack < Proc
  PROCS = {}
  class << self
    alias :real_new :new
  end
  GC.start
  def self.new block
    PROCS[block] ||= true
    r=real_new do |*o|
      ctx,function,this = o[0..2]
      varargs = []
      
      o[4].read_array_of_pointer(o[3]).each do |ptr|
        varargs <<  JS::Value.from_pointer_with_context(ctx,ptr)
      end

      this = JS::Object.from_pointer_with_context(ctx,this) if this.is_a?(FFI::Pointer)

      JS::Value.from_ruby(ctx,block.call(this,*varargs.map do |v| v.to_ruby end)).pointer
    end
    PROCS[r] = true
    r
  end
end

module JS
  def self.rb_ary2jsvalueref_ary(ctx,ary)
    return nil if ary.empty?
    vary = ary.map do |v| JS::Value.from_ruby(ctx,v) end
    jv_ary = FFI::MemoryPointer.new(:pointer,vary.length)
    jv_ary.write_array_of_pointer(vary)
    jv_ary  
  end

  def self.create_pointer_of_array type,ary,*dat
    r = nil
    if type == JS::Value
        r=self.rb_ary2jsvalueref_ary(dat[0],ary)
    elsif type == JS::String
        r=self.string_ary2jsstringref_ary(ary)
    end
    r
  end

  def self.string_ary2jsstringref_ary(r)
    vary = ary.map do |v| JS::String.create_with_utf8cstring(v) end
    jv_ary = FFI::MemoryPointer.new(:pointer,8)
    jv_ary.write_array_of_pointer(vary)
    jv_ary 
  end
  
  def self.execute_script(ctx,str,this=nil)
    str_ref = JS::String.create_with_utf8cstring(str)
    if JS::Lib.JSCheckScriptSyntax(ctx,str_ref,nil,0,nil)
      val = JS::Lib.JSEvaluateScript(ctx,str_ref,this,nil,0,nil)
    else
      raise "Script Syntax Error\n#{str_ref.to_s}"
    end
    str_ref.release
    JS::Value.from_pointer_with_context(ctx,val).to_ruby
  end
  
  def self.param_needs_context? a
    a.is_a?(Array) || a.is_a?(Hash) or a.is_a?(Method) or a.is_a?(Proc)
  end
end

module JS
  class Object
    include Enumerable
    def each
      if JS::Object.is_array(context,self)
        for i in 0..length-1
          yield self[i] if block_given?
        end      
      elsif  JS::Object.is_node_list(context,self)
        for i in 0..length-1
          yield self[i] if block_given?
        end 
      else
        properties.each do |n|
          yield(n) if block_given?
        end        
      end
    end
  
    def each_pair
      each do |n| yield(n,self[n]) end
    end
  end
end
