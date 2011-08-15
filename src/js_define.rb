require File.join('..',File.dirname(__FILE__),'tools','head_wrap')

class JS < Library
	class Object < IFace
	  def initialize
		super
		@ctor_method = "make"
		@ruby_name = "Object"
		@c_type_name = "JSObjectRef"
		@c_function_prefix = "JSObject"
		@source_header = File.join(File.dirname(__FILE__),'headers',"JSObjectRef.h")
		
		@ignore_functions << "JSObjectGetPrivate"
		@ignore_functions << "JSObjectGetPrivate"
		
		@ctor_functions << "JSObjectMake"
		@ctor_functions << "JSObjectMakeArray"
		@ctor_functions << "JSObjectMakeConstructor"
		@ctor_functions << "JSObjectMakeFunction"
		@ctor_functions << "JSObjectMakeFunctionWithCallback"
	  end
	end

	class Value < IFace
	  def initialize
		super
		@ctor_method = "make_undefined"
		@ruby_name = "Value"
		@c_type_name = "JSValueRef"
		@c_function_prefix = "JSValue"
		@source_header = File.join(File.dirname(__FILE__),'headers',"JSValueRef.h")
		
		#@ignore_functions << "JSObjectGetPrivate"
		#@ignore_functions << "JSObjectGetPrivate"
		
		@ctor_functions << "JSValueMakeNumber"
		@ctor_functions << "JSValueMakeString"
		@ctor_functions << "JSValueMakeObject"
		@ctor_functions << "JSValueMakeBoolean"
		@ctor_functions << "JSValueMakeNull"
		@ctor_functions << "JSValueMakeUndefined"
	  end
	end

	class GlobalContext < IFace
	  def initialize
		super

		@ruby_name = "GlobalContext"
		@c_type_name = "JSGlobalContextRef"
		@c_function_prefix = "JSGlobalContext"
		@source_header = File.join(File.dirname(__FILE__),'headers',"JSGlobalContextRef.h")
		@ctor_method = "create"
				
		@includes << "JS::Context"
		
		@ctor_functions << "JSGlobalContextCreate"
		@ctor_functions << "JSGlobalContextCreateInGroup"
	  end
	end

	class ContextGroup < IFace
	  def initialize
		super
		@ctor_method = "create"    
		@ruby_name = "ContextGroup"
		@c_type_name = "JSContextGroupRef"
		@c_function_prefix = "JSContextGroup"
		@source_header = File.join(File.dirname(__FILE__),'headers',"JSContextGroupRef.h")
		
		@ctor_functions << "JSContextGroupCreate"
	  end
	end

	class Context < IFace
	  def initialize
		super
		@is_module = true
		@ruby_name = "Context"
		@c_type_name = "JSContextRef"
		@c_function_prefix = "JSContext"
		@source_header = File.join(File.dirname(__FILE__),'headers',"JSContextRef.h")
	  end
	end

	 class String < IFace
	  def initialize
		super

		@ruby_name = "String"
		@c_type_name = "JSStringRef"
		@c_function_prefix = "JSString"
		@source_header = File.join(File.dirname(__FILE__),'headers',"JSStringRef.h")
		@ctor_method = "create_with_utf8cstring"
		
		@ctor_functions << 'JSStringCreateWithUTF8CString'
		@ctor_functions << 'JSStringCreateWithCharacters'
	  end
	end   

    class PropertyNameArray < IFace
      def initialize
      super
        @ruby_name = "PropertyNameArray"
	    @c_type_name = "JSPropertyNameArrayRef"
        @c_function_prefix = "JSPropertyNameArray"
	    @source_header = File.join(File.dirname(__FILE__),'headers',"JSPropertyNameArrayRef.h")
	  end
    end

	def initialize
	  super
	  @ffi_libs << 'libwebkitgtk-1.0'
	  
	  typedef :pointer,:JSClassRef
	  typedef :pointer,:JSObjectRef      
	  typedef :pointer,:JSStringRef
	  typedef :pointer,:JSValueRef
	  typedef :pointer,:JSPropertyNameArrayRef
	  typedef :pointer,:JSGlobalContextRef
	  typedef :pointer,:JSContextGroupRef        
	  typedef :pointer,:JSContextRef      
	  typedef :uint,:unsigned  
		
	  callback :JSObjectCallAsFunctionCallback,[:JSContextRef,:JSObjectRef,:JSObjectRef,:size_t,:pointer,:JSValueRef],:JSValueRef  
	  attach :JSEvaluateScript,[:JSContextRef,:JSStringRef,:JSObjectRef,:JSStringRef,:int,:JSValueRef],:JSValueRef  
	      
	  @lib_name = "JS"
	  @source_header = File.join(File.dirname(__FILE__),'headers',"JSBase.h")
	  @c_function_prefix = "JS"
	  
	  @target = File.join('..',File.dirname(__FILE__),"lib")
	  
	  add_hard_code('js_hard_code',File.join(File.dirname(__FILE__),'hard_code'))
	  add_hard_code('webkit_hard_code',File.join(File.dirname(__FILE__),'hard_code'))	  
	  
	  add_optional_require File.join(File.dirname(__FILE__),'hard_code','props2methods.rb')
	  
	  @ifaces << Object.new()
	  @ifaces << Value.new()
	  @ifaces << Context.new()
	  @ifaces << GlobalContext.new()
	  @ifaces << ContextGroup.new()
	  @ifaces << Value.new()
	  @ifaces << String.new()
	  @ifaces << PropertyNameArray.new
	  
	  force_param_type(:JSStringGetUTF8CString,1,:pointer)
	end
end

require 'javascript_sugar'



lib = JS.new
lib.define
sugar = JavaScript.new(lib)
lib.build(sugar)
