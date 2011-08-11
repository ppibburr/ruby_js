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
