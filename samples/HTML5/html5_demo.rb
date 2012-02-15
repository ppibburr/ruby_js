require 'JS/application'

class MyApp < JS::Application
  module MyRunner
	def on_render
	  a_div = document.createElement('div')
	  a_div.innerHTML = "I'm a 'DIV', Click me!!"
	  a_div.onclick = method(:on_click)
		
   	  document.body.appendChild a_div		
	end
		
	def on_click *o
	  alert("Click")
	end
  end

  def place_inspector insp
    w=Gtk::Window.new
    w.add v=WebKit::WebView.new
    w.show_all
    insp.show
    v.real
  end
	
  def on_render
	JS::Application.provide(context) do	
   	  use_runner MyRunner
    end.run
  end
end

MyApp.new.run





    
