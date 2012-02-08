
#       application.rb
             
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
require 'JS/desktop'
class JS::Application
  HTML_TEMPLATE = "<!doctype html><html><body></body></html>"
  attr_reader :gtk_window,:web_view,:window,:document,:global_object,:context,:gtk_scroll_window,:gtk_root_sizer
  def initialize title="RubyJS Application",width=400,height=400
    @gtk_window = Gtk::Window.new :toplevel
    @web_view = WebKit::WebView.new
    @gtk_window.add @gtk_root_sizer = Gtk::VBox.new
    @gtk_root_sizer.pack_start @gtk_scroll_window = Gtk::ScrolledWindow.new,true,true,0
    @gtk_scroll_window.add @web_view
    
    gtk_window.set_title title
    gtk_window.set_size_request width,height
    
    web_view.signal_connect "load-finished" do |view,frame|
      @context = frame.get_global_context
      @global_object = context.get_global_object
      @window = global_object.window
      @document = global_object.document
      on_render()
    end
    
    gtk_window.signal_connect "delete-event" do
      on_exit()
    end
    
    def on_exit
      Gtk.main_quit
    end
    
    def on_render
      
    end
    
    def run
      gtk_window.show_all
      web_view.load_html_string @html_template||HTML_TEMPLATE,@base_url||""
      Gtk.main
    end
  end
end

if __FILE__ == $0
	class MyApp < JS::Application
	  def initialize *o
	    super
	    @base_url = "file:///home/ppibburr/"
	  end
	  
	  def on_render
		img = document.createElement('img')
		img.src = "Pictures/rubyjs_extjs.png"
		document.body.appendChild img
		window.alert "Hello"  
	  end
	end

	MyApp.new.run
end
