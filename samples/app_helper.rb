require 'rubygems'
require 'JS/application'

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
