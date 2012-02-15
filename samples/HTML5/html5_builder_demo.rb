require 'JS/application'

class MyApp < JS::Application
	module MyRunner
		def on_render 
			alert "Ruby!"	
			
			build(document.body) do
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
		JS::Application.provide(context) do	
			use_runner MyRunner
		end.run
	end
end

MyApp.new.run





    
