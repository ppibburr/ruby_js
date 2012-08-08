
#       ruby_object.rb
             
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
  CLASS_DEF = JS::Lib::JSClassDefinition.new
  
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
    elsif object.private_methods.index(n.to_sym)
      true
    elsif object.respond_to?(:constants)
      !!object.constants.index(n.to_sym)
    else
      nil
    end   
  end
  def js_send this,*o,&b
    send *o,&b
  end
  def object_get_property n
    return nil if !object_has_property?(n)
    m = nil
    
    if object.respond_to?(n) or object.private_methods.index(n.to_sym)
      m =object.method(n)
    elsif object.respond_to?(:constants)
      m = object.const_get n.to_sym
    end
    
    o = nil
    
    if m.respond_to?(:call)
      o = JS::Object.new(context) do |*a|
        this = a.shift
        closure = nil
        if a.last.is_a?(JS::Object) and a.last.is_function
          closure = a.pop
          closure.context = context
        end
        q=m.call(*a) do |*args|
          closure.call(*args) if closure
        end
        JS::Value.from_ruby(context,q)
      end
    else
      o = m
    end

    v = JS::Value.from_ruby(context,o)#.to_ptr
    v.to_ptr
  end
end
