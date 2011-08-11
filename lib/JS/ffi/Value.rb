module JS
  module Lib
    class Value < JS::BaseObject

      # @param ctx => :JSContextRef
      def self.make_undefined(ctx)
        JS::Lib.JSValueMakeUndefined(ctx)
      end

      # @param ctx => :JSContextRef
      def self.make_null(ctx)
        JS::Lib.JSValueMakeNull(ctx)
      end

      # @param ctx => :JSContextRef
      # @param boolean => :bool
      def self.make_boolean(ctx,boolean)
        JS::Lib.JSValueMakeBoolean(ctx,boolean)
      end

      # @param ctx => :JSContextRef
      # @param number => :double
      def self.make_number(ctx,number)
        JS::Lib.JSValueMakeNumber(ctx,number)
      end

      # @param ctx => :JSContextRef
      # @param string => :JSStringRef
      def self.make_string(ctx,string)
        JS::Lib.JSValueMakeString(ctx,string)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      def get_type(ctx,value)
        JS::Lib.JSValueGetType(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      def is_undefined(ctx,value)
        JS::Lib.JSValueIsUndefined(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      def is_null(ctx,value)
        JS::Lib.JSValueIsNull(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      def is_boolean(ctx,value)
        JS::Lib.JSValueIsBoolean(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      def is_number(ctx,value)
        JS::Lib.JSValueIsNumber(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      def is_string(ctx,value)
        JS::Lib.JSValueIsString(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      def is_object(ctx,value)
        JS::Lib.JSValueIsObject(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # @param jsClass => :JSClassRef
      def is_object_of_class(ctx,value,jsClass)
        JS::Lib.JSValueIsObjectOfClass(ctx,value,jsClass)
      end

      # @param ctx => :JSContextRef
      # @param a => :JSValueRef
      # @param b => :JSValueRef
      # @param exception => :pointer
      def is_equal(ctx,a,b,exception)
        JS::Lib.JSValueIsEqual(ctx,a,b,exception)
      end

      # @param ctx => :JSContextRef
      # @param a => :JSValueRef
      # @param b => :JSValueRef
      def is_strict_equal(ctx,a,b)
        JS::Lib.JSValueIsStrictEqual(ctx,a,b)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # @param constructor => :JSObjectRef
      # @param exception => :pointer
      def is_instance_of_constructor(ctx,value,constructor,exception)
        JS::Lib.JSValueIsInstanceOfConstructor(ctx,value,constructor,exception)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      def to_boolean(ctx,value)
        JS::Lib.JSValueToBoolean(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # @param exception => :pointer
      def to_number(ctx,value,exception)
        JS::Lib.JSValueToNumber(ctx,value,exception)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # @param exception => :pointer
      def to_string_copy(ctx,value,exception)
        JS::Lib.JSValueToStringCopy(ctx,value,exception)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      # @param exception => :pointer
      def to_object(ctx,value,exception)
        JS::Lib.JSValueToObject(ctx,value,exception)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      def protect(ctx,value)
        JS::Lib.JSValueProtect(ctx,value)
      end

      # @param ctx => :JSContextRef
      # @param value => :JSValueRef
      def unprotect(ctx,value)
        JS::Lib.JSValueUnprotect(ctx,value)
      end
    end
  end
end
