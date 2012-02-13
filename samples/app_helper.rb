require 'rubygems'
require 'JS/application'

class MyApp < JS::Application
  def initialize *o
	super
	@base_url = "file:///home/ppibburr/"
  end
  
  def new *o,&b
    
  end
  
  def on_render

	img = document.createElement('img')
	img.src = "Pictures/rubyjs_extjs.png"
	document.body.appendChild img
	p :hghghghghghghghgh
	p global_object['Object'].has_property('rb_constructor')#.rb_constructor
	p global_object['Object']#.rb_constructor

	window.foo = proc do |*o| o[0] end
	window.foo 8
	window.foo = proc do |*o| o[0] end
	window.foo 8
	window.alert "Hello"  
  end
end

MyApp.new.run
