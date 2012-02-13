require 'JS/application'

module MyRunner
	extend JsApp::ConstLookup
	def on_render
		alert "Ruby!"
	end
end

class MyApp < JsApp
	def on_render
		JsApp.provide(context) do	
			include MyRunner
		end.new.on_render
	end
end

MyApp.new.run





    
