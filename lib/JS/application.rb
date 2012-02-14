
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
require 'JS/html5'
require 'JS/html5_dom_builder'

class JS::Application
  module Builder
	  def build_lib lib
			class_eval do
					n = lib.split(".")
					lo = lib.empty? ? @ctx.get_global_object : @ctx.get_global_object[n[0]]
					n.delete_at(0)
					n.each do |q|
						lo = lo[q]
					end
					ln = lib.empty? ? 'root' : n.last||lib
				  const_set(ln.capitalize,Module.new do
				    def self.set_lib o
				      @lib_object = o
				    end
						def self.const_missing c
							@lib_object[c.to_s] || super
						rescue
							super
						end
						
						def self.method_missing m,*o,&b;p :yui
							@lib_object.send m,*o,&b
						rescue;p :yui
							super
						end
						def self.lib_object
						  @lib_object
						end
				end)
				m=const_get(ln.capitalize)
				m.set_lib lo
				m
			end
	  end
  end
  
  class Provider
		class << self
		  attr_accessor :context
	  end
	  
	  extend Builder		
		
		attr_accessor :context
		
		def self.use_runner runner
			runner.module_eval do
				extend JS::Application::ConstLookup
			end
			include runner
		end
		
		def self.run
			new.on_render
		end
		
		def self.const_missing c
			self::Root.const_get(c)
		end
		
		def method_missing m,*o,&b
			global_object.send m,*o,&b
		rescue
			p m
			super
		end
		
		def this
			global_object
		end
		
		def build parent = nil,&b
			JS::DOM::Builder.build this,parent,&b
		end			
		
		def global_object
			self.class::Root.lib_object
		end	
		
		def initialize
			@context=global_object.context
		end  					
  end
  
  def self.provide(ctx,&b)
    klass = Class.new(Provider) do
			@ctx = ctx
			build_lib('')
			include self::Root
			extend self::Root
    end
    
    klass.class_eval &b
    klass
  end
  
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
      if frame.get_uri == @base_url
				@context = frame.get_global_context
				@global_object = context.get_global_object
				@window = global_object.window
				@document = global_object.document
				on_render()
			end
    end
    
    gtk_window.signal_connect "delete-event" do
      on_exit()
    end
  end  
	def on_exit
	  Gtk.main_quit
	end

	def on_render
	  
	end

	def run
	  gtk_window.show_all
	  web_view.load_html_string (@html_template||self.class::HTML_TEMPLATE),@base_url||="file://#{File.expand_path(File.dirname($0))}/"
	  Gtk.main
	end
	
	module ConstLookup
		def const_missing c
			@foo.const_get c
		end
		def included c
			@foo = c
		end
	end	
end
