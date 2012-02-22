require 'JS/application'

class MyApp < JS::Application
    HTML_TEMPLATE = "<html><head><script type='text/javascript'>
      w=Gtk.const_get('Window').new();
      w.set_size_request(400,400);
      w.signal_connect('show',function() {
        alert('hi');
        return true;
      });
      w.show();
      var gtkWindow=w;
    </script></head></html>"
    def initialize
      super
      @web_view.signal_connect "load-started" do |v,f|
        globj = f.get_global_context.get_global_object
        globj.Gtk = Gtk
      end
    end
	module MyRunner
		def on_render 
		  this.gtkWindow.set_title "Gtk from JS"
		end
	end
	
	def on_render
		JS::Application.provide(context) do	
			use_runner MyRunner
		end.run
	end
end

MyApp.new.run
