module JS
  module Lib
    class Object < JS::BaseObject

      # @param ctx => :JSContextRef
      # @param jsClass => :JSClassRef
      # @param data => :pointer
      # retuen => JSObjectRef
      def self.make(ctx,jsClass,data)
        JS::Lib.JSObjectMake(ctx,jsClass,data)
      end

      # @param ctx => :JSContextRef
      # @param name => :JSStringRef
      # @param callAsFunction => :JSObjectCallAsFunctionCallback
      # retuen => JSObjectRef
      def self.make_function_with_callback(ctx,name,callAsFunction)
        JS::Lib.JSObjectMakeFunctionWithCallback(ctx,name,callAsFunction)
      end

      # @param ctx => :JSContextRef
      # @param jsClass => :JSClassRef
      # @param callAsConstructor => :pointer
      # retuen => JSObjectRef
      def self.make_constructor(ctx,jsClass,callAsConstructor)
        JS::Lib.JSObjectMakeConstructor(ctx,jsClass,callAsConstructor)
      end

      # @param ctx => :JSContextRef
      # @param name => :JSStringRef
      # @param parameterCount => :unsigned
      # @param parameterNames => array of :JSStringRef
      # @param body => :JSStringRef
      # @param sourceURL => :JSStringRef
      # @param startingLineNumber => :int
      # @param exception => :pointer
      # retuen => JSObjectRef
      def self.make_function(ctx,name,parameterCount,parameterNames,body,sourceURL,startingLineNumber,exception)
        JS::Lib.JSObjectMakeFunction(ctx,name,parameterCount,parameterNames,body,sourceURL,startingLineNumber,exception)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # retuen => JSValueRef
      def get_prototype(ctx,object)
        JS::Lib.JSObjectGetPrototype(ctx,object)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # @param value => :JSValueRef
      # retuen => void
      def set_prototype(ctx,object,value)
        JS::Lib.JSObjectSetPrototype(ctx,object,value)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # @param propertyName => :JSStringRef
      # retuen => bool
      def has_property(ctx,object,propertyName)
        JS::Lib.JSObjectHasProperty(ctx,object,propertyName)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # @param propertyName => :JSStringRef
      # @param exception => :pointer
      # retuen => JSValueRef
      def get_property(ctx,object,propertyName,exception)
        JS::Lib.JSObjectGetProperty(ctx,object,propertyName,exception)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # @param propertyName => :JSStringRef
      # @param value => :JSValueRef
      # @param attributes => :pointer
      # @param exception => :pointer
      # retuen => void
      def set_property(ctx,object,propertyName,value,attributes,exception)
        JS::Lib.JSObjectSetProperty(ctx,object,propertyName,value,attributes,exception)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # @param propertyName => :JSStringRef
      # @param exception => :pointer
      # retuen => bool
      def delete_property(ctx,object,propertyName,exception)
        JS::Lib.JSObjectDeleteProperty(ctx,object,propertyName,exception)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # @param propertyIndex => :unsigned
      # @param exception => :pointer
      # retuen => JSValueRef
      def get_property_at_index(ctx,object,propertyIndex,exception)
        JS::Lib.JSObjectGetPropertyAtIndex(ctx,object,propertyIndex,exception)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # @param propertyIndex => :unsigned
      # @param value => :JSValueRef
      # @param exception => :pointer
      # retuen => void
      def set_property_at_index(ctx,object,propertyIndex,value,exception)
        JS::Lib.JSObjectSetPropertyAtIndex(ctx,object,propertyIndex,value,exception)
      end

      # @param object => :JSObjectRef
      # retuen => pointer
      def get_private(object)
        JS::Lib.JSObjectGetPrivate(object)
      end

      # @param object => :JSObjectRef
      # @param data => :pointer
      # retuen => bool
      def set_private(object,data)
        JS::Lib.JSObjectSetPrivate(object,data)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # retuen => bool
      def is_function(ctx,object)
        JS::Lib.JSObjectIsFunction(ctx,object)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # @param thisObject => :JSObjectRef
      # @param argumentCount => :size_t
      # @param arguments => array of :JSValueRef
      # @param exception => :pointer
      # retuen => JSValueRef
      def call_as_function(ctx,object,thisObject,argumentCount,arguments,exception)
        JS::Lib.JSObjectCallAsFunction(ctx,object,thisObject,argumentCount,arguments,exception)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # retuen => bool
      def is_constructor(ctx,object)
        JS::Lib.JSObjectIsConstructor(ctx,object)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # @param argumentCount => :size_t
      # @param arguments => array of :JSValueRef
      # @param exception => :pointer
      # retuen => JSObjectRef
      def call_as_constructor(ctx,object,argumentCount,arguments,exception)
        JS::Lib.JSObjectCallAsConstructor(ctx,object,argumentCount,arguments,exception)
      end

      # @param ctx => :JSContextRef
      # @param object => :JSObjectRef
      # retuen => JSPropertyNameArrayRef
      def copy_property_names(ctx,object)
        JS::Lib.JSObjectCopyPropertyNames(ctx,object)
      end
    end
  end
end
