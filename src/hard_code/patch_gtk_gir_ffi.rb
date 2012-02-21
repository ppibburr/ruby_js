Gtk
Gtk::Object
class Gtk::Object
	def signal_connect n,&b
	  GObject.signal_connect(self,n,&b)
	end
end
Gtk::Window
class Gtk::Window
  class << self
    alias :real_new :new
  end
  
  def self.new *o
    if o.empty?
      o << :toplevel
    end
    real_new *o
  end
end
