
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
    

    # Creates a JavaScript object.
    #
    # @param [FFI::Pointer] data A void* to set as the object's private data. Pass nil to specify no private data.
    # @param [JSClassRef] jsClass The JS::Class to assign to the object. Pass nil to use the default object class.
    # @param [JS::Context] ctx The execution context to use.
    # @return [JS::Object] A JS::Object with the given class and private data.
    def self.make(ctx,jsClass = nil,data = nil)
      res = super(ctx,jsClass,data)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    # Convenience method for creating a JavaScript function with a given callback as its implementation.
    #
    # @param [JS::String] name A JS::String containing the function's name. This will be used when converting the function to string. Pass nil to create an anonymous function.
    # @param [Proc] callAsFunction The JS::ObjectCallAsFunctionCallback to invoke when the function is called.
    # @param [JS::Context] ctx The execution context to use.
    # @return [JS::Object] A JS::Object that is a function. The object's prototype will be the default function prototype.
    def self.make_function_with_callback(ctx,name = nil,&callAsFunction)
      name = JS::String.create_with_utf8cstring(name)
      callAsFunction = JS::CallBack.new(callAsFunction)
      res = super(ctx,name,callAsFunction)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    # Convenience method for creating a JavaScript constructor.
    #
    # @param [FFI::Pointer] callAsConstructor A JS::ObjectCallAsConstructorCallback to invoke when your constructor is used in a 'new' expression. Pass nil to use the default object constructor.
    # @param [JSClassRef] jsClass A JS::Class that is the class your constructor will assign to the objects its constructs. jsClass will be used to set the constructor's .prototype property, and to evaluate 'instanceof' expressions. Pass nil to use the default object class.
    # @param [JS::Context] ctx The execution context to use.
    # @return [JS::Object] A JS::Object that is a constructor. The object's prototype will be the default object prototype.
    def self.make_constructor(ctx,jsClass = nil,callAsConstructor = nil)
      res = super(ctx,jsClass,callAsConstructor)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    # Creates a JavaScript Array object.
    #
    # @param [Array] arguments An Array of JS::Value's of data to populate the Array with. Pass nil if argumentCount is 0.
    # @param [FFI::Pointer] exception A pointer to a JS::ValueRef in which to store an exception, if any. Pass nil if you do not care to store an exception.
    # @param [Integer] argumentCount An integer count of the number of arguments in arguments.
    # @param [JS::Context] ctx The execution context to use.
    # @return [JS::Object] A JS::Object that is an Array.
    def self.make_array(ctx,argumentCount,arguments,exception = nil)
      res = super(ctx,argumentCount,arguments,exception)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    # Creates a function with a given script as its body.
    #
    # @param [JS::String] name A JS::String containing the function's name. This will be used when converting the function to string. Pass nil to create an anonymous function.
    # @param [JS::String] body A JS::String containing the script to use as the function's body.
    # @param [Array] parameterNames An Array of JS::String's containing the names of the function's parameters. Pass nil if parameterCount is 0.
    # @param [FFI::Pointer] exception A pointer to a JS::ValueRef in which to store a syntax error exception, if any. Pass nil if you do not care to store a syntax error exception.
    # @param [JS::Context] ctx The execution context to use.
    # @param [Integer] parameterCount An integer count of the number of parameter names in parameterNames.
    # @param [Integer] startingLineNumber An integer value specifying the script's starting line number in the file located at sourceURL. This is only used when reporting exceptions.
    # @param [JS::String] sourceURL A JS::String containing a URL for the script's source file. This is only used when reporting exceptions. Pass nil if you do not care to include source file information in exceptions.
    # @return [JS::Object] A JS::Object that is a function, or NULL if either body or parameterNames contains a syntax error. The object's prototype will be the default function prototype.
    def self.make_function(ctx,name,parameterCount,parameterNames,body,sourceURL,startingLineNumber,exception = nil)
      name = JS::String.create_with_utf8cstring(name)
      body = JS::String.create_with_utf8cstring(body)
      sourceURL = JS::String.create_with_utf8cstring(sourceURL)
      res = super(ctx,name,parameterCount,parameterNames,body,sourceURL,startingLineNumber,exception)
      wrap = self.new(:pointer=>res)
      wrap.context = ctx
      return wrap
    end

    # Gets an object's prototype.
    #
    # @return [JS::Value] A JS::Value that is the object's prototype.
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

    # Sets an object's prototype.
    #
    # @param [JS::Value] value A JS::Value to set as the object's prototype.
    def set_prototype(value)
      value = JS::Value.from_ruby(context,value)
      res = super(context,self,value)
      return res
    end

    # Tests whether an object has a given property.
    #
    # @param [JS::String] propertyName A JS::String containing the property's name.
    # @return [boolean] true if the object has a property whose name matches propertyName, otherwise false.
    def has_property(propertyName)
      propertyName = JS::String.create_with_utf8cstring(propertyName)
      res = super(context,self,propertyName)
      return res
    end

    # Gets a property from an object.
    #
    # @param [JS::String] propertyName A JS::String containing the property's name.
    # @param [FFI::Pointer] exception A pointer to a JS::ValueRef in which to store an exception, if any. Pass nil if you do not care to store an exception.
    # @return [JS::Value] The property's value if object has the property, otherwise the undefined value.
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

    # Sets a property on an object.
    #
    # @param [FFI::Pointer] attributes A logically ORed set of JSPropertyAttributes to give to the property.
    # @param [JS::String] propertyName A JS::String containing the property's name.
    # @param [FFI::Pointer] exception A pointer to a JS::ValueRef in which to store an exception, if any. Pass nil if you do not care to store an exception.
    # @param [JS::Value] value A JS::Value to use as the property's value.
    def set_property(propertyName,value,attributes = nil,exception = nil)
      propertyName = JS::String.create_with_utf8cstring(propertyName)
      value = JS::Value.from_ruby(context,value)
      res = super(context,self,propertyName,value,attributes,exception)
      return res
    end

    # Deletes a property from an object.
    #
    # @param [JS::String] propertyName A JS::String containing the property's name.
    # @param [FFI::Pointer] exception A pointer to a JS::ValueRef in which to store an exception, if any. Pass nil if you do not care to store an exception.
    # @return [boolean] true if the delete operation succeeds, otherwise false (for example, if the property has the kJSPropertyAttributeDontDelete attribute set).
    def delete_property(propertyName,exception = nil)
      propertyName = JS::String.create_with_utf8cstring(propertyName)
      res = super(context,self,propertyName,exception)
      return res
    end

    # Gets a property from an object by numeric index.
    #
    # @param [FFI::Pointer] exception A pointer to a JS::ValueRef in which to store an exception, if any. Pass nil if you do not care to store an exception.
    # @param [Integer] propertyIndex An integer value that is the property's name.
    # @return [JS::Value] The property's value if object has the property, otherwise the undefined value.
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

    # Sets a property on an object by numeric index.
    #
    # @param [FFI::Pointer] exception A pointer to a JS::ValueRef in which to store an exception, if any. Pass nil if you do not care to store an exception.
    # @param [JS::Value] value A JS::Value to use as the property's value.
    # @param [Integer] propertyIndex The property's name as a number.
    def set_property_at_index(propertyIndex,value,exception = nil)
      value = JS::Value.from_ruby(context,value)
      res = super(context,self,propertyIndex,value,exception)
      return res
    end

    # Gets an object's private data.
    #
    # @return [FFI::Pointer] A void* that is the object's private data, if the object has private data, otherwise NULL.
    def get_private()
      res = super(self)
      return res
    end

    # Sets a pointer to private data on an object.
    #
    # @param [FFI::Pointer] data A void* to set as the object's private data.
    # @return [boolean] true if object can store private data, otherwise false.
    def set_private(data)
      res = super(self,data)
      return res
    end

    # Tests whether an object can be called as a function.
    #
    # @return [boolean] true if the object can be called as a function, otherwise false.
    def is_function()
      res = super(context,self)
      return res
    end

    # @note A convienience method is at JS::Object#call
    # @see Object#call
    # Calls an object as a function.
    #
    # @param [Array] arguments An Array of JS::Value's of arguments to pass to the function. Pass nil if argumentCount is 0.
    # @param [JS::Object] thisObject The object to use as "this," or nil to use the global object as "this."
    # @param [FFI::Pointer] exception A pointer to a JS::ValueRef in which to store an exception, if any. Pass nil if you do not care to store an exception.
    # @return [JS::Value] The JS::Value that results from calling object as a function, or NULL if an exception is thrown or object is not a function.
    def call_as_function(thisObject = nil,argumentCount = 0,arguments = nil,exception = nil)
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

    # Tests whether an object can be called as a constructor.
    #
    # @return [boolean] true if the object can be called as a constructor, otherwise false.
    def is_constructor()
      res = super(context,self)
      return res
    end

    # Calls an object as a constructor.
    #
    # @param [Array] arguments An Array of JS::Value's of arguments to pass to the constructor. Pass nil if argumentCount is 0.
    # @param [FFI::Pointer] exception A pointer to a JS::ValueRef in which to store an exception, if any. Pass nil if you do not care to store an exception.
    # @return [JS::Object] The JS::Object that results from calling object as a constructor, or NULL if an exception is thrown or object is not a constructor.
    def call_as_constructor(argumentCount = 0,arguments = nil,exception = nil)
      res = super(context,self,argumentCount,arguments,exception)
      return check_use(res) || JS::Object.from_pointer_with_context(context,res)
    end

    # Gets the names of an object's enumerable properties.
    #
    # @return [JS::PropertyNameArray] A JS::PropertyNameArray containing the names object's enumerable properties. Ownership follows the Create Rule.
    def copy_property_names()
      res = super(context,self)
      return JS::PropertyNameArray.new(res)
    end
  end
end
