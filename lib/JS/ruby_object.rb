
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
      p o1
      q = m.call *o1
      JS::Value.from_ruby(context,q)
    end

    v = JS::Value.from_ruby(context,o)#.to_ptr
    v.to_ptr
  end
end
