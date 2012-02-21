
class StatusBar < Gtk::Statusbar
	def initialize
		super
		@iconbox = Gtk::EventBox.new()
		@iconbox.add(Gtk::Image.new(Gtk::Stock::INFO, Gtk::IconSize::BUTTON))
		pack_start(@iconbox, false, false, 6)
		@iconbox.hide_all()
	end

	def display(text, context=nil)
		cid = get_context_id("pywebkitgtk")
		push(cid, text)
	end

	def show_javascript_info()
		@iconbox.show()
	end

	def hide_javascript_info()
		@iconbox.hide()
	end
end
