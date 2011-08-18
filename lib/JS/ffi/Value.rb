
#       Value.rb
             
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
    class Value < JS::BaseObject

      #       Creates a JavaScript value of the undefined type.
      #
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         The unique undefined value.
      def self.make_undefined(ctx)
        JS::Lib.JSValueMakeUndefined(ctx)
      end

      #       Creates a JavaScript value of the null type.
      #
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         The unique null value.
      def self.make_null(ctx)
        JS::Lib.JSValueMakeNull(ctx)
      end

      #       Creates a JavaScript value of the boolean type.
      #
      # @param [:bool] boolean  The bool to assign to the newly created JSValue.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         A JSValue of the boolean type, representing the value of boolean.
      def self.make_boolean(ctx,boolean)
        JS::Lib.JSValueMakeBoolean(ctx,boolean)
      end

      #       Creates a JavaScript value of the number type.
      #
      # @param [:double] number   The double to assign to the newly created JSValue.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         A JSValue of the number type, representing the value of number.
      def self.make_number(ctx,number)
        JS::Lib.JSValueMakeNumber(ctx,number)
      end

      #       Creates a JavaScript value of the string type.
      #
      # @param [:JSContextRef] ctx  The execution context to use.
      # @param [:JSStringRef] string   The JSString to assign to the newly created JSValue. The
      # @return         A JSValue of the string type, representing the value of string.
      def self.make_string(ctx,string)
        JS::Lib.JSValueMakeString(ctx,string)
      end

      #       Returns a JavaScript value's type.
      #
      # @param [:JSValueRef] value    The JSValue whose type you want to obtain.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         A value of type JSType that identifies value's type.
      def get_type(ctx,value)
        JS::Lib.JSValueGetType(ctx,value)
      end

      #       Tests whether a JavaScript value's type is the undefined type.
      #
      # @param [:JSValueRef] value    The JSValue to test.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         true if value's type is the undefined type, otherwise false.
      def is_undefined(ctx,value)
        JS::Lib.JSValueIsUndefined(ctx,value)
      end

      #       Tests whether a JavaScript value's type is the null type.
      #
      # @param [:JSValueRef] value    The JSValue to test.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         true if value's type is the null type, otherwise false.
      def is_null(ctx,value)
        JS::Lib.JSValueIsNull(ctx,value)
      end

      #       Tests whether a JavaScript value's type is the boolean type.
      #
      # @param [:JSValueRef] value    The JSValue to test.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         true if value's type is the boolean type, otherwise false.
      def is_boolean(ctx,value)
        JS::Lib.JSValueIsBoolean(ctx,value)
      end

      #       Tests whether a JavaScript value's type is the number type.
      #
      # @param [:JSValueRef] value    The JSValue to test.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         true if value's type is the number type, otherwise false.
      def is_number(ctx,value)
        JS::Lib.JSValueIsNumber(ctx,value)
      end

      #       Tests whether a JavaScript value's type is the string type.
      #
      # @param [:JSValueRef] value    The JSValue to test.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         true if value's type is the string type, otherwise false.
      def is_string(ctx,value)
        JS::Lib.JSValueIsString(ctx,value)
      end

      #       Tests whether a JavaScript value's type is the object type.
      #
      # @param [:JSValueRef] value    The JSValue to test.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         true if value's type is the object type, otherwise false.
      def is_object(ctx,value)
        JS::Lib.JSValueIsObject(ctx,value)
      end

      # Tests whether a JavaScript value is an object with a given class in its class chain.
      #
      # @param [:JSClassRef] jsClass The JSClass to test against.
      # @param [:JSValueRef] value The JSValue to test.
      # @param [:JSContextRef] ctx The execution context to use.
      # @return true if value is an object and has jsClass in its class chain, otherwise false.
      def is_object_of_class(ctx,value,jsClass)
        JS::Lib.JSValueIsObjectOfClass(ctx,value,jsClass)
      end

      # Tests whether two JavaScript values are equal, as compared by the JS == operator.
      #
      # @param [:JSValueRef] a The first value to test.
      # @param [:JSValueRef] b The second value to test.
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @param [:JSContextRef] ctx The execution context to use.
      # @return true if the two values are equal, false if they are not equal or an exception is thrown.
      def is_equal(ctx,a,b,exception)
        JS::Lib.JSValueIsEqual(ctx,a,b,exception)
      end

      #       Tests whether two JavaScript values are strict equal, as compared by the JS === operator.
      #
      # @param [:JSValueRef] a        The first value to test.
      # @param [:JSValueRef] b        The second value to test.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         true if the two values are strict equal, otherwise false.
      def is_strict_equal(ctx,a,b)
        JS::Lib.JSValueIsStrictEqual(ctx,a,b)
      end

      # Tests whether a JavaScript value is an object constructed by a given constructor, as compared by the JS instanceof operator.
      #
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @param [:JSObjectRef] constructor The constructor to test against.
      # @param [:JSValueRef] value The JSValue to test.
      # @param [:JSContextRef] ctx The execution context to use.
      # @return true if value is an object constructed by constructor, as compared by the JS instanceof operator, otherwise false.
      def is_instance_of_constructor(ctx,value,constructor,exception)
        JS::Lib.JSValueIsInstanceOfConstructor(ctx,value,constructor,exception)
      end

      #       Converts a JavaScript value to boolean and returns the resulting boolean.
      #
      # @param [:JSValueRef] value    The JSValue to convert.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         The boolean result of conversion.
      def to_boolean(ctx,value)
        JS::Lib.JSValueToBoolean(ctx,value)
      end

      #       Converts a JavaScript value to number and returns the resulting number.
      #
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @param [:JSValueRef] value    The JSValue to convert.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         The numeric result of conversion, or NaN if an exception is thrown.
      def to_number(ctx,value,exception)
        JS::Lib.JSValueToNumber(ctx,value,exception)
      end

      #       Converts a JavaScript value to string and copies the result into a JavaScript string.
      #
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @param [:JSValueRef] value    The JSValue to convert.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         A JSString with the result of conversion, or NULL if an exception is thrown. Ownership follows the Create Rule.
      def to_string_copy(ctx,value,exception)
        JS::Lib.JSValueToStringCopy(ctx,value,exception)
      end

      # Converts a JavaScript value to object and returns the resulting object.
      #
      # @param [:pointer] exception A pointer to a JSValueRef in which to store an exception, if any. Pass NULL if you do not care to store an exception.
      # @param [:JSValueRef] value    The JSValue to convert.
      # @param [:JSContextRef] ctx  The execution context to use.
      # @return         The JSObject result of conversion, or NULL if an exception is thrown.
      def to_object(ctx,value,exception)
        JS::Lib.JSValueToObject(ctx,value,exception)
      end

      # Protects a JavaScript value from garbage collection.
      #
      # @param [:JSValueRef] value The JSValue to protect.
      # @param [:JSContextRef] ctx The execution context to use.
      def protect(ctx,value)
        JS::Lib.JSValueProtect(ctx,value)
      end

      #       Unprotects a JavaScript value from garbage collection.
      #
      # @param [:JSValueRef] value    The JSValue to unprotect.
      # @param [:JSContextRef] ctx      The execution context to use.
      def unprotect(ctx,value)
        JS::Lib.JSValueUnprotect(ctx,value)
      end
    end
  end
end
