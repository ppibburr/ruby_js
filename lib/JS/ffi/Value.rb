
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

      # @param ctx => :JSContextRef
      # retuen => JSValueRef
      def self.make_undefined(ctx)
        JS::Lib.JSValueMakeUndefined(ctx)
      end

      # @param ctx => :JSContextRef
      # retuen => JSValueRef
      def self.make_null(ctx)
        JS::Lib.JSValueMakeNull(ctx)
      end

      # @param ctx => :JSContextRef
      # @param boolean => :bool
      # retuen => JSValueRef
      def self.make_boolean(ctx,boolean)
        JS::Lib.JSValueMakeBoolean(ctx,boolean)
      end

      # @param ctx => :JSContextRef
      # @param number => :double
      # retuen => JSValueRef
      def self.make_number(ctx,number)
        JS::Lib.JSValueMakeNumber(ctx,number)
      end

      # @param ctx => :JSContextRef
      # @param string => :JSStringRef
      # retuen => JSValueRef
      def self.make_string(ctx,string)
        JS::Lib.JSValueMakeString(ctx,string)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # retuen => pointer
      def get_type(ctx,value)
        JS::Lib.JSValueGetType(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # retuen => bool
      def is_undefined(ctx,value)
        JS::Lib.JSValueIsUndefined(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # retuen => bool
      def is_null(ctx,value)
        JS::Lib.JSValueIsNull(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # retuen => bool
      def is_boolean(ctx,value)
        JS::Lib.JSValueIsBoolean(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # retuen => bool
      def is_number(ctx,value)
        JS::Lib.JSValueIsNumber(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # retuen => bool
      def is_string(ctx,value)
        JS::Lib.JSValueIsString(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # retuen => bool
      def is_object(ctx,value)
        JS::Lib.JSValueIsObject(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # @param jsClass => :JSClassRef
      # retuen => bool
      def is_object_of_class(ctx,value,jsClass)
        JS::Lib.JSValueIsObjectOfClass(ctx,value,jsClass)
      end

      # @param ctx => :JSContextRef
      # @param a => :JSValueRef
      # @param b => :JSValueRef
      # @param exception => :pointer
      # retuen => bool
      def is_equal(ctx,a,b,exception)
        JS::Lib.JSValueIsEqual(ctx,a,b,exception)
      end

      # @param ctx => :JSContextRef
      # @param a => :JSValueRef
      # @param b => :JSValueRef
      # retuen => bool
      def is_strict_equal(ctx,a,b)
        JS::Lib.JSValueIsStrictEqual(ctx,a,b)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # @param constructor => :JSObjectRef
      # @param exception => :pointer
      # retuen => bool
      def is_instance_of_constructor(ctx,value,constructor,exception)
        JS::Lib.JSValueIsInstanceOfConstructor(ctx,value,constructor,exception)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # retuen => bool
      def to_boolean(ctx,value)
        JS::Lib.JSValueToBoolean(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # @param exception => :pointer
      # retuen => double
      def to_number(ctx,value,exception)
        JS::Lib.JSValueToNumber(ctx,value,exception)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # @param exception => :pointer
      # retuen => JSStringRef
      def to_string_copy(ctx,value,exception)
        JS::Lib.JSValueToStringCopy(ctx,value,exception)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # @param exception => :pointer
      # retuen => JSObjectRef
      def to_object(ctx,value,exception)
        JS::Lib.JSValueToObject(ctx,value,exception)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # retuen => void
      def protect(ctx,value)
        JS::Lib.JSValueProtect(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # retuen => void
      def unprotect(ctx,value)
        JS::Lib.JSValueUnprotect(ctx,value)
      end
    end
  end
end
