require 'JS/application'

class MyApp < JS::Application
    HTML_TEMPLATE = "<html><head><script type='text/javascript'>
    var Gtk = null;
    var gtk_from_js = function() {
      w=Gtk.const_get('Window').new();
      w.set_size_request(400,400);
      w.show();
      return w;
    };
    </script></head></html>"
	module MyRunner
		def on_render 
		  this.Gtk = JS::RubyObject.new(this.context,Gtk)
		  this.gtk_from_js.set_title("Gtk From JavaScript")
		end
	end
	
	def on_render
		JS::Application.provide(context) do	
			use_runner MyRunner
		end.run
	end
end

MyApp.new.run
