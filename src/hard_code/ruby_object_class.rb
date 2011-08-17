module JS
  module Lib
    typedef :pointer,:JSClassAttributes
    typedef :pointer,:JSPropertyNameAccumulatorRef
    typedef :int,:JSType
    
    callback :JSObjectGetPropertyCallback,[:JSContextRef,:JSObjectRef,:JSStringRef,:pointer],:JSValueRef
    callback :JSObjectSetPropertyCallback,[:JSContextRef,:JSObjectRef,:JSStringRef,:JSValueRef,:pointer],:bool
    callback :JSObjectHasPropertyCallback,[:JSContextRef,:JSObjectRef,:JSStringRef],:bool
    callback :JSObjectDeletePropertyCallback,[:JSContextRef,:JSObjectRef,:JSStringRef,:pointer],:bool
    callback :JSObjectCallAsConstructorCallback,[:JSContextRef,:JSObjectRef,:pointer,:pointer],:JSValueRef
    callback :JSObjectHasInstanceCallback,[:JSContextRef,:JSObjectRef,:JSValueRef,:pointer],:bool
    callback :JSObjectConvertToTypeCallback,[:JSContextRef,:JSObjectRef,:JSType,:pointer],:JSValueRef
    callback :JSObjectCallAsConstructorCallback,[:JSContextRef,:JSObjectRef,:size_t,:pointer,:pointer],:JSObjectRef
    callback :JSObjectInitializeCallback,[:JSContextRef,:JSObjectRef,:pointer,:pointer],:JSValueRef
    callback :JSObjectFinalizeCallback,[:JSObjectRef],:void
    callback :JSObjectGetPropertyNamesCallback,[:JSContextRef,:JSObjectRef,:JSPropertyNameAccumulatorRef],:void

    attach_function :JSClassCreate,[:pointer],:pointer

    class JSClassDefinition < FFI::Struct
      layout :version,:int,
      :attributes,:JSClassAttributes,
      :className,:pointer,
      :parentClass,:JSClassRef,
      :staticValues,:pointer,
      :staticFunctions,:pointer,
      :initialize,:JSObjectInitializeCallback,
      :finalize,:JSObjectFinalizeCallback,
      :hasProperty,:JSObjectHasPropertyCallback,
      :getProperty,:JSObjectGetPropertyCallback,
      :setProperty,:JSObjectSetPropertyCallback,
      :deleteProperty,:JSObjectDeletePropertyCallback,
      :getPropertyNames,:JSObjectGetPropertyNamesCallback,
      :callAsFunction,:JSObjectCallAsFunctionCallback,
      :callAsConstructor,:JSObjectCallAsConstructorCallback,
      :hasInstance,:JSObjectHasInstanceCallback,
      :convertToType,:JSObjectConvertToTypeCallback
    end
  end
end


