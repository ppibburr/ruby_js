
#       Object.rb
             
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
module JS
  class Object < JS::Lib::Object

    class << self
      alias :real_new :new
    end  
      
    def self.new *o
      if o[0].is_a? Hash and o[0][:pointer] and o.length == 1
        real_new o[0][:pointer]
      else
        return JS::Object.make(*o)
      end
    end
      

  attr_accessor :context
  
  def self.from_pointer_with_context(ctx,ptr)
    res = self.new(:pointer=>ptr)
    res.context = ctx
    res
  end
    

    def self.make(ctx,jsClass = nil,data = nil)
      res = super(ctx,jsClass,data)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    def self.make_function_with_callback(ctx,name,&callAsFunction)
      name = JS::String.create_with_utf8cstring(name)
      callAsFunction = JS::CallBack.new(callAsFunction)
      res = super(ctx,name,callAsFunction)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    def self.make_constructor(ctx,jsClass = nil,callAsConstructor = nil)
      res = super(ctx,jsClass,callAsConstructor)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    def self.make_array(ctx,argumentCount,arguments,exception = nil)
      res = super(ctx,argumentCount,arguments,exception)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    def self.make_function(ctx,name,parameterCount,parameterNames,body,sourceURL,startingLineNumber,exception = nil)
      name = JS::String.create_with_utf8cstring(name)
      body = JS::String.create_with_utf8cstring(body)
      sourceURL = JS::String.create_with_utf8cstring(sourceURL)
      res = super(ctx,name,parameterCount,parameterNames,body,sourceURL,startingLineNumber,exception)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    def get_prototype()
      res = super(context,self)

    
      val_ref = JS::Value.from_pointer_with_context(context,res)
      ret = val_ref.to_ruby
      if ret.is_a?(JS::Value)
        return check_use(ret) || is_self(ret) || ret
      else
        return check_use(ret) || ret
      end
    
        
    end

    def set_prototype(value)
      value = JS::Value.from_ruby(context,value)
      res = super(context,self,value)
      return res
    end

    def has_property(propertyName)
      propertyName = JS::String.create_with_utf8cstring(propertyName)
      res = super(context,self,propertyName)
      return res
    end

    def get_property(propertyName,exception = nil)
      propertyName = JS::String.create_with_utf8cstring(propertyName)
      res = super(context,self,propertyName,exception)

    
      val_ref = JS::Value.from_pointer_with_context(context,res)
      ret = val_ref.to_ruby
      if ret.is_a?(JS::Value)
        return check_use(ret) || is_self(ret) || ret
      else
        return check_use(ret) || ret
      end
    
        
    end

    def set_property(propertyName,value,attributes = nil,exception = nil)
      propertyName = JS::String.create_with_utf8cstring(propertyName)
      value = JS::Value.from_ruby(context,value)
      res = super(context,self,propertyName,value,attributes,exception)
      return res
    end

    def delete_property(propertyName,exception = nil)
      propertyName = JS::String.create_with_utf8cstring(propertyName)
      res = super(context,self,propertyName,exception)
      return res
    end

    def get_property_at_index(propertyIndex,exception = nil)
      res = super(context,self,propertyIndex,exception)

    
      val_ref = JS::Value.from_pointer_with_context(context,res)
      ret = val_ref.to_ruby
      if ret.is_a?(JS::Value)
        return check_use(ret) || is_self(ret) || ret
      else
        return check_use(ret) || ret
      end
    
        
    end

    def set_property_at_index(propertyIndex,value,exception = nil)
      value = JS::Value.from_ruby(context,value)
      res = super(context,self,propertyIndex,value,exception)
      return res
    end

    def get_private()
      res = super(self)
      return res
    end

    def set_private(data)
      res = super(self,data)
      return res
    end

    def is_function()
      res = super(context,self)
      return res
    end

    def call_as_function(thisObject = nil,argumentCount = nil,arguments = nil,exception = nil)
      thisObject = JS::Object.from_ruby(context,thisObject)
      res = super(context,self,thisObject,argumentCount,arguments,exception)

    
      val_ref = JS::Value.from_pointer_with_context(context,res)
      ret = val_ref.to_ruby
      if ret.is_a?(JS::Value)
        return check_use(ret) || is_self(ret) || ret
      else
        return check_use(ret) || ret
      end
    
        
    end

    def is_constructor()
      res = super(context,self)
      return res
    end

    def call_as_constructor(argumentCount,arguments = nil,exception = nil)
      res = super(context,self,argumentCount,arguments,exception)
      return check_use(res) || JS::Object.from_pointer_with_context(context,res)
    end

    def copy_property_names()
      res = super(context,self)
      return JS::PropertyNameArray.new(res)
    end
  end
end
