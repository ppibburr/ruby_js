class Toolbar < Gtk::Toolbar
	attr_reader :browser
	def initialize
		super()

		@browser = nil

		# navigational buttons
		@back = Gtk::ToolButton.new(Gtk::Stock::GO_BACK)
		@back.set_tooltip(Gtk::Tooltips.new(), 'Back')
		@back.sensitive = false
		@back.signal_connect('clicked') do |o|
			_go_back_cb(*o)
		end

		self.insert(-1,@back)

		@forward = Gtk::ToolButton.new(Gtk::Stock::GO_FORWARD)
		@forward.set_tooltip(Gtk::Tooltips.new(),'Forward')
		@forward.sensitive = false
		@forward.signal_connect('clicked') do |o| _go_forward_cb(*o) end
		insert(-1, @forward)
		@forward.show()

		@stop_and_reload = Gtk::ToolButton.new(Gtk::Stock::REFRESH)
		@stop_and_reload.set_tooltip(Gtk::Tooltips.new(),'Stop and reload current page')
		@stop_and_reload.signal_connect('clicked') do |o| _stop_and_reload_cb(*o) end
		insert(-1,@stop_and_reload)
		@stop_and_reload.show()
		@loading = false

		insert(-1,Gtk::SeparatorToolItem.new())

		# zoom buttons
		@zoom_in = Gtk::ToolButton.new(Gtk::Stock::ZOOM_IN)
		@zoom_in.set_tooltip(Gtk::Tooltips.new(), 'Zoom in')
		@zoom_in.signal_connect('clicked') do |o| _zoom_in_cb(*o) end
		insert(-1,@zoom_in)
		@zoom_in.show()

		@zoom_out = Gtk::ToolButton.new(Gtk::Stock::ZOOM_OUT)
		@zoom_out.set_tooltip(Gtk::Tooltips.new(), 'Zoom out')
		@zoom_out.signal_connect('clicked') do |o| _zoom_out_cb(*o) end
		insert(-1, @zoom_out)
		@zoom_out.show()

		@zoom_hundred = Gtk::ToolButton.new(Gtk::Stock::ZOOM_100)
		@zoom_hundred.set_tooltip(Gtk::Tooltips.new(), '100% zoom')
		@zoom_hundred.signal_connect('clicked') do |o| _zoom_hundred_cb(*o) end
		insert(-1,@zoom_hundred)
		@zoom_hundred.show()

		insert(-1,Gtk::SeparatorToolItem.new())

		# location entry
		@entry = Gtk::Entry.new()
		@entry.signal_connect('activate') do |o| _entry_activate_cb(*o) end
		@current_uri = nil

		entry_item = Gtk::ToolItem.new()
		entry_item.set_expand(true)
		entry_item.add(@entry)
		@entry.show()

		insert(-1,entry_item)
		entry_item.show()

		# location entry
		@search = Gtk::Entry.new()
		@search.signal_connect('activate') do |o| _search_activate_cb(*o) end
		search_item = Gtk::ToolItem.new()
		search_item.set_expand(false)
		search_item.add(@search)
		@search.show()

		insert(-1,search_item)
		search_item.show()
		
		@entry.set_primary_icon_stock Gtk::Stock::NETWORK
	end
  
    def set_location_icon pb
      @entry.set_primary_icon_pixbuf pb
    end
  
    def _search_activate_cb widget
      str = "http://google.com/search?q=#{widget.text}"
      @browser.open str
    end

	def set_view browser
		@browser = browser
		return if !browser
		@browser.set_full_content_zoom(true)
		@browser.signal_connect("title-changed") do |o| _title_changed_cb(*o) end
		_update_navigation_buttons()
		_set_address browser.get_uri
	end

	def set_loading loading
		@loading = loading

		if @loading
				_show_stop_icon
				@stop_and_reload.set_tooltip(Gtk::Tooltips.new(), 'Stop')
		else
				_show_reload_icon()
				@stop_and_reload.set_tooltip(Gtk::Tooltips.new(), 'Reload')
		end
		_update_navigation_buttons()
	end

	def _set_address(address)
		@entry.text = address
		@current_uri = address
	end

	def _update_navigation_buttons()
		can_go_back = @browser.can_go_back()
		@back.sensitive = can_go_back

		can_go_forward = @browser.can_go_forward()
		@forward.sensitive = can_go_forward
	end

	def _entry_activate_cb(entry)
	  addr = entry.text
	  addr = "http://"+addr unless addr =~ /^[a-zA-Z]+\:\/\//
		@browser.open(addr)
	end

	def _go_back_cb(button)
		@browser.go_back()
	end

	def _go_forward_cb(button)
		@browser.go_forward()
	end

	def _title_changed_cb(widget, frame, title)
		_set_address(frame.get_uri())
	end

	def _stop_and_reload_cb(button)
		if @loading
				@browser.stop_loading()
		else
				@browser.reload()
		end
	end

	def _show_stop_icon()
		@stop_and_reload.set_stock_id(Gtk::Stock::CANCEL)
	end

	def _show_reload_icon()
		@stop_and_reload.set_stock_id(Gtk::Stock::REFRESH)
	end

	def _zoom_in_cb( widget)
		"""Zoom into the page"""
		@browser.zoom_in()
	end

	def _zoom_out_cb( widget)\
		"""Zoom out of the page"""
		@browser.zoom_out()
	end

	def _zoom_hundred_cb(widget)
		"""Zoom 100%"""
		if !(@browser.get_zoom_level() == 1.0)
				@browser.set_zoom_level(1.0)
		end
	end
end
