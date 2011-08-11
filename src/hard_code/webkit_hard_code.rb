GirFFI.setup("WebKit")

module WebKit
  module MissingFunctions
    extend FFI::Library
    ffi_lib 'webkitgtk-1.0'
    
    attach_function :webkit_web_frame_get_global_context,[:pointer],:pointer
  end
  
  WebKit::WebFrame
  class WebFrame
    def get_global_context
      JS::GlobalContext.new(:pointer=>WebKit::MissingFunctions.webkit_web_frame_get_global_context(self))
    end
  end
end
