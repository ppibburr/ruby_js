Gtk
Gtk::Object
class Gtk::Object
	def signal_connect n,&b
	  GObject.signal_connect(self,n,&b)
	end
end
