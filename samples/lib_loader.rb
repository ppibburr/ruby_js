require 'JS/application'

class MyApp < JsApp
	module MyRunner
		extend JsApp::ConstLookup
		def on_render
			alert "Ruby!"
			
			a_div = document.createElement('div')
			a_div.innerHTML = "I'm a 'DIV', Click me!!"
			a_div.onclick = method(:on_click)
			
			document.body.appendChild a_div			
			
			build(a_div) do
				div do
				  style.backgroundColor = "#cecece"
					
					a :href=>"http://google.com" do
					  style.color = "black"
						text "Google"
					end
					
				  onclick do |t,e|
				    alert("Click 2")
				    e.stopPropagation
				  end					
				end
			end
		end
		
		def on_click *o
		  alert("Click")
		end
	end
	
	def on_render
		JsApp.provide(context) do	
			include MyRunner
		end.new.on_render
	end
end

MyApp.new.run





    
