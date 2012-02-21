# browser_demo.rb
# Ported from pywebkitgtk/source/browse/trunk/demos/webbrowser.py
# Added download support
# A HTML5 web browser with WebInspector support

require 'JS/application'
require './inspector'
require 'open-uri'
require './toolbar'
require './view'
require './statusbar'
require './controls/tabbook'
require './viewbook.rb'
require './viewpage.rb'
require './browser_handle_view_signals'
require './download_dialog'

class Browser < Gtk::Window
  REGEXP={:is_protocol=>/^[a-zA-Z]+\:\/\/(.*)/}
  
  attr_reader :toolbar,:view_book,:statusbar
	def initialize
		super
      @_icons_ = {}
      Gtk::Window.set_default_icon get_icon('')
		@loading = false
		
		@toolbar = Toolbar.new()
		@view_book = ViewBook.new(self)
		@statusbar = StatusBar.new()

    @toolbar.set_location_icon get_icon("")

    create_page()
    		vbox = Gtk::VBox.new()
		vbox.pack_start(@toolbar, expand=false, fill=false)
		vbox.pack_start(@view_book,true,true)
		vbox.pack_end(@statusbar, expand=false, fill=false)

		add(vbox)
		set_default_size(600, 480)
		signal_connect('destroy') do  Gtk.main_quit end
		show_all()
		
    get_active_view.load_uri("http://gtk.org")#("<html><head><link rel='icon' href=''></link><title>About Browser.rb</title></head><body></body></html>",'about://')
    

	end
	
	GC.start
	def on_page_create pg
	  pg.view.connect_signals(self)
	end
	
	def create_page()
	  @view_book.add_page
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
	  @view_book.get_active
	end

	def get_active_view
		return nil if !(page=get_active_page)
		page.view
	end
	
	def get_dom_window view
	  view.get_main_frame.get_global_context.get_global_object.window
	end
end


webbrowser = Browser.new()
Gtk.main()
