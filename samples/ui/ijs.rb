require 'JS'
require 'JS/webkit'
require 'JS/props2methods'

v=WebKit::WebView.new
v.load_html_string "</html><body></body></html>",nil
(q=v.get_main_frame.get_property!('real').inspect) =~ /ptr.*0x([a-zA-Z0-9]+)/
p q
GLOBAL = WebKit::WebFrame.new(:ptr=>FFI::Pointer.new($1.to_i(16))).get_global_context.get_global_object
def document
  GLOBAL.document
end
