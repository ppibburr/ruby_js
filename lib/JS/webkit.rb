
#       webkit.rb
             
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
