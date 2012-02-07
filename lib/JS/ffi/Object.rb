
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
  module Lib
    class Object < JS::BaseObject

      # Creates a JavaScript object.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSClassRef] jsClass The JSClass to assign to the object. Pass NULL to use the default object class.
      # @param [:pointer] data A void* to set as the object's private data. Pass NULL to specify no private data.
      # @return A JSObject with the given class and private data.
      def self.make(ctx,jsClass,data)
        JS::Lib.JSObjectMake(ctx,jsClass,data)
      end

      # Convenience method for creating a JavaScript function with a given callback as its implementation.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSStringRef] name A JSString containing the function's name. This will be used when converting the function to string. Pass NULL to create an anonymous function.
      # @param [:JSObjectCallAsFunctionCallback] callAsFunction The JSObjectCallAsFunctionCallback to invoke when the function is called.
      # @return A JSObject that is a function. The object's prototype will be the default function prototype.
      def self.make_function_with_callback(ctx,name,callAsFunction)
        JS::Lib.JSObjectMakeFunctionWithCallback(ctx,name,callAsFunction)
      end

      # Convenience method for creating a JavaScript constructor.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSClassRef] jsClass A JSClass that is the class your constructor will assign to the objects its constructs. jsClass will be used to set the constructor's .prototype property, and to evaluate 'instanceof' expressions. Pass NULL to use the default object class.
      # @param [:pointer] callAsConstructor A JSObjectCallAsConstructorCallback to invoke when your constructor is used in a 'new' expression. Pass NULL to use the default object constructor.
      # @return A JSObject that is a constructor. The object's prototype will be the default object prototype.
      def self.make_constructor(ctx,jsClass,callAsConstructor)
        JS::Lib.JSObjectMakeConstructor(ctx,jsClass,callAsConstructor)
      end

      # Creates a JavaScript Array object.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:size_t] argumentCount An integer count of the number of arguments in arguments.
      # @param [:JSValueRef] arguments A JSValue array of data to populate the Array with. Pass NULL if argumentCount is 0.
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @return A JSObject that is an Array.
      def self.make_array(ctx,argumentCount,arguments,exception)
        JS::Lib.JSObjectMakeArray(ctx,argumentCount,arguments,exception)
      end

      # Creates a function with a given script as its body.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSStringRef] name A JSString containing the function's name. This will be used when converting the function to string. Pass NULL to create an anonymous function.
      # @param [:unsigned] parameterCount An integer count of the number of parameter names in parameterNames.
      # @param [:JSStringRef] parameterNames A JSString array containing the names of the function's parameters. Pass NULL if parameterCount is 0.
      # @param [:JSStringRef] body A JSString containing the script to use as the function's body.
      # @param [:JSStringRef] sourceURL A JSString containing a URL for the script's source file. This is only used when reporting exceptions. Pass NULL if you do not care to include source file information in exceptions.
      # @param [:int] startingLineNumber An integer value specifying the script's starting line number in the file located at sourceURL. This is only used when reporting exceptions.
      # @param [:pointer] exception A pointer to a JSValueRef in which to store a syntax error exception, if any. Pass NULL if you do not care to store a syntax error exception.
      # @return A JSObject that is a function, or NULL if either body or parameterNames contains a syntax error. The object's prototype will be the default function prototype.
      def self.make_function(ctx,name,parameterCount,parameterNames,body,sourceURL,startingLineNumber,exception)
        JS::Lib.JSObjectMakeFunction(ctx,name,parameterCount,parameterNames,body,sourceURL,startingLineNumber,exception)
      end

      # Gets an object's prototype.
      #
      # @param [:JSContextRef] ctx  The execution context to use.
      # @param [:JSObjectRef] object A JSObject whose prototype you want to get.
      # @return A JSValue that is the object's prototype.
      def get_prototype(ctx,object)
        JS::Lib.JSObjectGetPrototype(ctx,object)
      end

      # Sets an object's prototype.
      #
      # @param [:JSContextRef] ctx  The execution context to use.
      # @param [:JSObjectRef] object The JSObject whose prototype you want to set.
      # @param [:JSValueRef] value A JSValue to set as the object's prototype.
      def set_prototype(ctx,object,value)
        JS::Lib.JSObjectSetPrototype(ctx,object,value)
      end

      # Tests whether an object has a given property.
      #
      # @param [:JSObjectRef] object The JSObject to test.
      # @param [:JSStringRef] propertyName A JSString containing the property's name.
      # @return true if the object has a property whose name matches propertyName, otherwise false.
      def has_property(ctx,object,propertyName)
        JS::Lib.JSObjectHasProperty(ctx,object,propertyName)
      end

      # Gets a property from an object.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSObjectRef] object The JSObject whose property you want to get.
      # @param [:JSStringRef] propertyName A JSString containing the property's name.
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @return The property's value if object has the property, otherwise the undefined value.
      def get_property(ctx,object,propertyName,exception)
        JS::Lib.JSObjectGetProperty(ctx,object,propertyName,exception)
      end

      # Sets a property on an object.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSObjectRef] object The JSObject whose property you want to set.
      # @param [:JSStringRef] propertyName A JSString containing the property's name.
      # @param [:JSValueRef] value A JSValue to use as the property's value.
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @param [:pointer] attributes A logically ORed set of JSPropertyAttributes to give to the property.
      def set_property(ctx,object,propertyName,value,attributes,exception)
        JS::Lib.JSObjectSetProperty(ctx,object,propertyName,value,attributes,exception)
      end

      # Deletes a property from an object.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSObjectRef] object The JSObject whose property you want to delete.
      # @param [:JSStringRef] propertyName A JSString containing the property's name.
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @return true if the delete operation succeeds, otherwise false (for example, if the property has the kJSPropertyAttributeDontDelete attribute set).
      def delete_property(ctx,object,propertyName,exception)
        JS::Lib.JSObjectDeleteProperty(ctx,object,propertyName,exception)
      end

      # Gets a property from an object by numeric index.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSObjectRef] object The JSObject whose property you want to get.
      # @param [:unsigned] propertyIndex An integer value that is the property's name.
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @return The property's value if object has the property, otherwise the undefined value.
      def get_property_at_index(ctx,object,propertyIndex,exception)
        JS::Lib.JSObjectGetPropertyAtIndex(ctx,object,propertyIndex,exception)
      end

      # Sets a property on an object by numeric index.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSObjectRef] object The JSObject whose property you want to set.
      # @param [:unsigned] propertyIndex The property's name as a number.
      # @param [:JSValueRef] value A JSValue to use as the property's value.
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      def set_property_at_index(ctx,object,propertyIndex,value,exception)
        JS::Lib.JSObjectSetPropertyAtIndex(ctx,object,propertyIndex,value,exception)
      end

      # Gets an object's private data.
      #
      # @param [:JSObjectRef] object A JSObject whose private data you want to get.
      # @return A void* that is the object's private data, if the object has private data, otherwise NULL.
      def get_private(object)
        JS::Lib.JSObjectGetPrivate(object)
      end

      # Sets a pointer to private data on an object.
      #
      # @param [:JSObjectRef] object The JSObject whose private data you want to set.
      # @param [:pointer] data A void* to set as the object's private data.
      # @return true if object can store private data, otherwise false.
      def set_private(object,data)
        JS::Lib.JSObjectSetPrivate(object,data)
      end

      # Tests whether an object can be called as a function.
      #
      # @param [:JSContextRef] ctx  The execution context to use.
      # @param [:JSObjectRef] object The JSObject to test.
      # @return true if the object can be called as a function, otherwise false.
      def is_function(ctx,object)
        JS::Lib.JSObjectIsFunction(ctx,object)
      end

      # Calls an object as a function.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSObjectRef] object The JSObject to call as a function.
      # @param [:JSObjectRef] thisObject The object to use as "this," or NULL to use the global object as "this."
      # @param [:size_t] argumentCount An integer count of the number of arguments in arguments.
      # @param [:JSValueRef] arguments A JSValue array of arguments to pass to the function. Pass NULL if argumentCount is 0.
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @return The JSValue that results from calling object as a function, or NULL if an exception is thrown or object is not a function.
      def call_as_function(ctx,object,thisObject,argumentCount,arguments,exception)
        JS::Lib.JSObjectCallAsFunction(ctx,object,thisObject,argumentCount,arguments,exception)
      end

      # Tests whether an object can be called as a constructor.
      #
      # @param [:JSContextRef] ctx  The execution context to use.
      # @param [:JSObjectRef] object The JSObject to test.
      # @return true if the object can be called as a constructor, otherwise false.
      def is_constructor(ctx,object)
        JS::Lib.JSObjectIsConstructor(ctx,object)
      end

      # Calls an object as a constructor.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSObjectRef] object The JSObject to call as a constructor.
      # @param [:size_t] argumentCount An integer count of the number of arguments in arguments.
      # @param [:JSValueRef] arguments A JSValue array of arguments to pass to the constructor. Pass NULL if argumentCount is 0.
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @return The JSObject that results from calling object as a constructor, or NULL if an exception is thrown or object is not a constructor.
      def call_as_constructor(ctx,object,argumentCount,arguments,exception)
        JS::Lib.JSObjectCallAsConstructor(ctx,object,argumentCount,arguments,exception)
      end

      # Gets the names of an object's enumerable properties.
      #
      # @param [:JSContextRef] ctx The execution context to use.
      # @param [:JSObjectRef] object The object whose property names you want to get.
      # @return A JSPropertyNameArray containing the names object's enumerable properties. Ownership follows the Create Rule.
      def copy_property_names(ctx,object)
        JS::Lib.JSObjectCopyPropertyNames(ctx,object)
      end
    end
  end
end
