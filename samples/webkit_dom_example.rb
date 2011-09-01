
#       webkit_dom_example.rb
             
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
require 'rubygems'
require 'ffi'

require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')
require File.join(File.dirname(__FILE__),'..','lib','JS','webkit')
require "uki2"

w = Gtk::Window.new()
v = WebKit::WebView.new

v.load_html_string("""<!doctype html><html>
<style type='text/css'>
#{DATA.read}
</style>
<body></body></html>""",nil)
w.add v
w.show_all



def ruby_do_dom ctx
  globj = ctx.get_global_object
  doc = globj['document']

  uw=Uki2::Window.new(doc.body,:position=>[100,5],:size=>[300,230])
  uw.add b=Uki2::Container.new(uw)   
  b.add Uki2::Label.new(b,"""Some text to demonstrate a
   multiline area of formatted text that
   etc ...
  """,:size=>[-1,50])
  b.add Uki2::HRule.new(b,:position=>[0,63]) 
  b.add Uki2::Entry.new(b,:position=>[0,77])
  b.add Uki2::TextView.new(b,File.read(__FILE__),:position=>[0,103])
  uw.show
end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |yv,f|
  ruby_do_dom(f.get_global_context)
end

Gtk.main
__END__
.drawable {
  position: absolute;
  height: 100%;
  width: 100%;
}

.shown {

}

.hidden {
  display: none;
}

.panel {
  border-color: #666;
  border-style: solid;
  border-width: 1px;
  border-top-left-radius: 0.5em;
  border-top-right-radius: 0.5em;
  background-color: #eeeeef;
  color: black;
}

.panel_handle {
  background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#ebf1f6), color-stop(50%,#abd3ee), color-stop(51%,#89c3eb), color-stop(100%,#d5ebfb));
  border-top-left-radius: 0.5em;
  border-top-right-radius: 0.5em;
  border-style:solid;
  border-width:1px;
  border-bottom-color:#666;
  border-left-color:#ebebeb;
  border-top-color:#ebebeb;
  border-right-color:#ebebeb;  
  height: 20px;
  text-align: center;  
  color: #666;
}

.label {
  height: 18px;
  font-family:     "Courier New",
                    Courier,
                    monospace;
  font-size: 10pt;
  margin: 0px;
  padding: 1px;  
}

.window {

}


.entry {
  background-color: white;
  box-shadow: inset 1px 1px 1px #666;
  border-color: #666;
  border-style: solid;
  border-width: 1px;
  border-top-left-radius: 0.25em;
  border-top-right-radius: 0.25em;
  border-bottom-left-radius: 0.25em;
  border-bottom-right-radius: 0.25em;
  font-family:     "Courier New",
                    Courier,
                    monospace;
  font-size: 10pt;
  margin: 0px;
  padding: 1px;
}

.rule {
  box-shadow: inset 1px 1px 2px #666;
  border-color: #bbcfce;
  border-style: solid;
  border-width: 1px;
  border-top-left-radius: 0.25em;
  border-top-right-radius: 0.25em;
  border-bottom-left-radius: 0.25em;
  border-bottom-right-radius: 0.25em;
}

.scrollable {
  overflow: auto;
 -webkit-scrollbar-face-color: #cacaca;
 scrollbar-highlight-color: #cacaca;
 scrollbar-3dlight-color: #cacaca;
 scrollbar-darkshadow-color: #cacaca;
 scrollbar-shadow-color: #cacaca;
 scrollbar-arrow-color: #000000;
 scrollbar-track-color: #cacaca;  
}

.textarea {

}
