module JS
  Config = {}
  Config[:WebKit] = {:lib=>"webkitgtk-1.0"}
  Config[:WebKit][:Gtk] = {:type=>:standard,:lib=>"gtk-x11-2.0"} 
end

if JS::Config[:WebKit][:Gtk][:type] == :ffi
begin
  require 'gir_ffi'
  GirFFI.setup "Gtk"
  require File.join(File.dirname(__FILE__),'webkit_hard_code_minimal')
rescue
  puts "Sorry. Problem with GirFFI. falling back to standard Gtk2"
  require File.join(File.dirname(__FILE__),'patch_standard_gtk')
  require File.join(File.dirname(__FILE__),'webkit_hard_code_full')
end

else
  require File.join(File.dirname(__FILE__),'patch_standard_gtk')
  require File.join(File.dirname(__FILE__),'webkit_hard_code_full')
end

WebKit::WebView
class WebKit::WebView
  def signal_connect s,&b
    f = FFI::Function.new(:bool,[:pointer,:pointer]) do |*o|
      if s=~/^load/
        v = self
        f = WebKit::WebFrame.new(:ptr=>o[1])
        b.call v,f
      else
        b.call *o
      end
    end
    GObject.signal_connect_data self,s,f,nil,nil,0
  end
end
