# browser_demo.rb
# Ported from pywebkitgtk/source/browse/trunk/demos/webbrowser.py
# Added download support
# A HTML5 web browser with WebInspector support

require 'JS/application'
require './inspector'
require 'open-uri'

class WebToolbar < Gtk::Toolbar
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
        @search.primary_icon_stock = Gtk::Stock::FIND
		search_item = Gtk::ToolItem.new()
		search_item.set_expand(false)
		search_item.add(@search)
		@search.show()

		insert(-1,search_item)
		search_item.show()
		
		@entry.set_primary_icon_stock Gtk::Stock::NETWORK
	end
  
    def _set_location_icon pb
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

class BrowserPage < WebKit::WebView
  attr_reader :browser
    def initialize(browser=1)
			super()
			settings = get_settings()
			settings.set_property("enable-developer-extras", true)
			
			signal_connect('load-started')                do |o| browser._loading_start_cb(*o)  end
			signal_connect('load-progress-changed')       do |o| browser._loading_progress_cb(*o) end
			signal_connect('load-finished')               do |o| browser._loading_stop_cb(*o)  end
			signal_connect("title-changed")               do |o| browser._title_changed_cb(*o)  end
			signal_connect("hovering-over-link")          do |o| browser._hover_link_cb(*o)  end
			signal_connect("status-bar-text-changed")     do |o| browser._statusbar_text_changed_cb(*o)  end
			signal_connect("icon-loaded")                 do |o| browser._icon_loaded_cb(*o) end
			signal_connect("selection-changed")           do |o| browser._selection_changed_cb(*o)  end
			signal_connect("set-scroll-adjustments")      do |o| browser._set_scroll_adjustments_cb(*o) end
			signal_connect("populate-popup")              do |o| browser._populate_popup(*o)  end
			signal_connect("console-message")             do |o| browser._javascript_console_message_cb(*o) end
			signal_connect("script-alert")                do |o| browser._javascript_script_alert_cb(*o)  end
			signal_connect("script-confirm")              do |o| browser._javascript_script_confirm_cb(*o)  end
			signal_connect("script-prompt")               do |o| browser._javascript_script_prompt_cb(*o)  end
			signal_connect("mime-type-policy-decision-requested")  do |o| browser.handle_mime_type(*o) end
			signal_connect("download-requested")                   do |o| browser.handle_download(*o) end
			signal_connect("navigation-policy-decision-requested") do |o| browser.handle_navigation_request(*o) end
			signal_connect("new-window-policy-decision-requested") do |o| browser.handle_new_window_request(*o) end
			signal_connect("create-web-view")                      do |o| browser.handle_create_view(*o) end
			signal_connect("web-view-ready")                       do |o| browser.on_view_ready(*o) end
    end
end

class WebStatusBar < Gtk::Statusbar
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

require './controls/tabbook'

class ViewBook < TabBook
  attr_reader :browser
  def initialize parent
    super()
    @browser = parent
    signal_connect "switch-page" do |book,page,i|
      @browser.set_active get_nth_page(i) unless i == n_pages-1
    end
  end
  
  def pages
    a = super
    a.delete_at a.length-1
    a
  end
  
  def create_page bool=true
    pg = ViewPage.new(browser)
    pg.show_all
    handle = pg.signal_connect("realize") do
      #TODO: clean up code that attempted to solve what this fixes
      pg.view.open("about://self")
      pg.signal_handler_disconnect(handle)
      false
    end if bool
    pg
  end
  
  def set_view pg
    self.page = page_num(pg)
    pg 
  end
  
  def get_page_by_view view
    pages.find do |pg| pg.view == view end
  end
end

class ViewPage < Gtk::Frame
  attr_reader :view,:dock,:inspector
  def initialize browser
    super()
    @view = BrowserPage.new(browser)
    @inspector = Inspector.new(view.get_inspector())
    @dock = Gtk::Frame.new

    inspector.set_dock dock
    add vbox = Gtk::VBox.new

    scrolled_window = Gtk::ScrolledWindow.new()
    scrolled_window.hscrollbar_policy = Gtk::POLICY_AUTOMATIC
    scrolled_window.vscrollbar_policy = Gtk::POLICY_AUTOMATIC
    scrolled_window.add(view)
    scrolled_window

    vbox.pack_start scrolled_window,true,true
    vbox.pack_start dock,true,true
    
    signal_connect 'expose-event' do
      @inspector.on_page_show
      false
    end
  end
end

class WebBrowser < Gtk::Window
  attr_reader :toolbar,:view_book,:statusbar
	def initialize
		super
        @_icons_ = {}
		# logging.debug("initializing web browser window")

		@loading = false

		@toolbar = WebToolbar.new()

		@view_book = ViewBook.new(self)

		create_page("self://about")

		@statusbar = WebStatusBar.new()

		vbox = Gtk::VBox.new()
		vbox.pack_start(@toolbar, expand=false, fill=false)
		vbox.pack_start(@view_book,true,true)
		vbox.pack_end(@statusbar, expand=false, fill=false)

		add(vbox)
		set_default_size(600, 480)

		signal_connect('destroy') do  Gtk.main_quit end

		show_all()
	end

	def set_active pg
		return if !pg
		@active_page = pg
		@toolbar.set_view pg ? pg.view : nil
		set_title pg.view.get_title
		@toolbar._set_location_icon get_icon(pg.view.get_icon_uri)
		pg
	end
	
	def get_icon uri
	  if uri.is_a? Symbol
	    return render_icon(uri,Gtk::IconSize::SMALL_TOOLBAR)
	  end
	  if !@_icons_[uri]
	    if uri.empty?
				@_icons_[uri] = Gdk::Pixbuf.new(File.join(File.expand_path(File.dirname(__FILE__)),"icons","default.png"))
	    else
	      begin # this block is for unhandable icon formats and ssl icon's
	        File.open(temp = File.basename(uri),'w') do |f| f.puts open(uri).read end
	        @_icons_[uri] = Gdk::Pixbuf.new(temp)
	      rescue 
	        return get_icon("")
	      end
	    end
	  end
	  @_icons_[uri]
	end
	
	def get_active_page
	  @active_page
	end

	def get_active_view
		return nil if !@active_page
		@active_page.view
	end

	def create_page bool=true
		page = @view_book.create_page(bool)
		@view_book.add page
		page
	end

	def handle_create_view view,frame
		create_page(false).view
	end

	def handle_new_window_request view,frame,req,action,policy
		if true
			false
		end
	end

	def on_view_ready view
		pg = @view_book.get_page_by_view(view)
		@view_book.set_view(pg)
		false
	end

	# Download everything webview cant show
	def handle_mime_type view,frame,request,type,policy
		if get_active_view.can_show_mime_type(type)
			return nil
		else
			policy.download
			return true
		end
	end

	# confirm to save, then prompt where to save, abort on cancel
	def handle_download view,download
		dialog = Gtk::MessageDialog.new(self,Gtk::Dialog::DESTROY_WITH_PARENT,Gtk::MessageDialog::QUESTION,Gtk::MessageDialog::BUTTONS_OK_CANCEL,"Save file: '%s' ?" % fn=download.get_suggested_filename)
		resp = dialog.run
		dialog.destroy

		if resp == Gtk::Dialog::RESPONSE_OK
			dialog = Gtk::FileChooserDialog.new("Save File As ...",self,Gtk::FileChooser::ACTION_SAVE,nil,[ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ],[ Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT ])

			odg = nil

			dialog.filename = File.join(ENV['HOME'],'Downloads',fn)
			dialog.current_name = File.basename(fn)
			dialog.do_overwrite_confirmation = true

			dialog.signal_connect('response') do |w, r|
				odg = case r
					when Gtk::Dialog::RESPONSE_ACCEPT
						filename = dialog.filename
						puts "'ACCEPT' download filename is {{ #{filename} }}"

						download.set_destination_uri("file://"+filename)

						download.signal_connect('notify::progress') do |dl,progress|
							puts "Download: #{filename}, #{dl.get_property('progress')*100} complete"
							false
						end

						download.signal_connect('notify::status') do |dl,status|
							case dl.get_property('status').inspect
								when /error/
									puts "Download: #{filename}, error. ABORTED"
								when /finished/
									puts "Download: #{filename}, complete!"
								when /cancelled/
							else
							end
						end

						true
					when Gtk::Dialog::RESPONSE_CANCEL;
						"'CANCEL' (#{r}) button pressed"
						false
					else
						false
				end
				dialog.destroy
			end

			dialog.run

			return odg
		else
			return false
		end
	end

	def _loading_start_cb(view, frame)
		main_frame = (get_active_view||view).get_main_frame()
		if !get_active_view
		  @toolbar.set_view view
		end
		if frame == main_frame
			set_title("loading " + (frame.get_title().to_s + " " + frame.get_uri().to_s))
		end
		@toolbar.set_loading(true)
	end

	def _loading_stop_cb(view, frame)
		# FIXME: another frame may still be loading?
		@toolbar.set_loading(false)
	end

	def _loading_progress_cb(view, progress)
		_set_progress(progress)
	end

	def _set_progress(progress)
	    progress = progress.to_s
	    def progress.write q
	      self << q if q
	    end
		@statusbar.display(progress)
	end

	def _title_changed_cb( view, frame, title)
		 set_title(title)
		 page = @view_book.get_page_by_view(view)
         @view_book.set_tab_text page,title
    rescue
	end

	def _hover_link_cb(view, title, url)
		if view and url
			@statusbar.display(url)
		else
			@statusbar.display('')
		end
	end

	def _statusbar_text_changed_cb(view, text)
		#if text:
		@statusbar.display(text)
	end

	def _icon_loaded_cb(view,uri)
	  pb = get_icon(uri)
	  @toolbar._set_location_icon pb if view == get_active_view
	  pg = @view_book.get_page_by_view(view);p :ert
	  @view_book.set_tab_icon pg,pb
	  pb
	end

	def _selection_changed_cb(*o)
		"selection changed"
	end

	def _set_scroll_adjustments_cb( view, hadjustment=nil, vadjustment=nil)
		if hadjustment and vadjustment
			["horizontal adjustment: %d", hadjustment.value]
			["vertical adjustmnet: %d", vadjustment.value]
			nil
		end
	end
GC.start
	def handle_navigation_request( view, frame, req,action,policy)
		case req.get_uri
		when /^about\:\/\/self(.*)/
		    handle = view.signal_connect('load-finished') do |vw,fr|
		      on_self fr.get_global_context.get_global_object,vw
		      view.real.signal_handler_disconnect(handle)
		    end
			return false
		else
			return false
		end
	end

	def on_self globj,view
		document = globj.document
		runner = JS::Application.provide(globj.context) do
			use_runner AboutSelf
		end.new
		runner.set_app self
		runner.set_view view
		runner.on_render
	end

	def _javascript_console_message_cb(view, message, line, sourceid)
		@statusbar.show_javascript_info()
	end

	def _javascript_script_alert_cb( view, frame, message)
	  true
	end

	def _javascript_script_confirm_cb( view, frame, message, isConfirmed)
		
	end

	def _javascript_script_prompt_cb( view, frame, message, default, text)
		
	end

	def _populate_popup( view, menu)
		aboutitem = Gtk::MenuItem.new(label="About RubyJS")
		menu.append(aboutitem)
		aboutitem.signal_connect('activate') do |o| _about_pywebkitgtk_cb(*o) end
		menu.show_all()
	end

	def _about_pywebkitgtk_cb(widget)
		get_active_view.open("http://github.com/ppibburr/ruby_js")
	end
end

module AboutSelf
  def on_render
    @timeout_return = true
  
    window.onunload do
      @timeout_return = false
    end
  
    pg = @app.view_book.get_page_by_view(@view)
    @app.view_book.set_tab_icon(pg,ico=@app.get_icon(Gtk::Stock::INFO))
    @app.toolbar._set_address "about://self"
    head = document.getElementsByTagName("head")[0]
    
    build(head) do
      title do text "Self" end
    end
    
    build(document.body) do
      h3 do
        text "WebBrowser.rb"
      end
      table :id=>"dl" do
        th do text "Downloads" end
        tr do
          style.backgroundColor = "#00D2FF" 
          td do text "File "end; td do text "Source" end; td do text "Completed" end; td do text "Time Left" end
        end
      end
    end
    
    
    downloads()
  end
  
  def downloads
    @dls = []
    10.times do @dls.push ["foo.bar","http://foo.bar",0.87,"0.55 sec"] end
    
    update()
   
    poll(document)
  end
  
  def update document=self.document
    return false unless @timeout_return
		colors = ["#cecece","silver"]
		evn_odd = 0
		formatters = [proc do |q| q.to_s end,proc do |q| q.to_s end,proc do |q| "%0.2f" % (100*q) end,proc do |q| q.to_s end]
		@dls.reverse.each_with_index do |dl,i|
		  dl[2]=(rand(100)/100.0)
		  dl[3]="#{rand(100).to_f} sec"
		  evn_odd += 1
      evn_odd = 0 if evn_odd == 2
			if (row=document.getElementById("dl#{i}")) #and dl.active?
				cells = row.getElementsByTagName('td')
				dl[2..3].each_with_index do |q,idx|
				  cells[2+idx].innerHTML = formatters[2+idx].call(q)
				end
			else
				build(document.getElementById("dl")) do
					tr :id=>"dl#{i}" do
						style.backgroundColor = colors[evn_odd]
						td do
							text dl[0]
						end
						td do
							text dl[1]
						end
						td :align=>"right" do
							text (dl[2]*100).to_s
						end
						td :align=>"right" do
							text dl[3]
						end
					end
				end
			end
		end
		true
  rescue
    # probally unloaded the page
    return false
  end
  
  def poll doc
      GLib::Timeout.add(300){ update() }
  end
  
  def set_app app
    @app = app
  end
  
  def set_view view
    @view = view
  end
  
  def on_leave
    @thread.kill
  end
end

webbrowser = WebBrowser.new()
Gtk.main()
