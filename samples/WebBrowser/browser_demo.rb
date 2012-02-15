# browser_demo.rb
# Ported from pywebkitgtk/source/browse/trunk/demos/webbrowser.py
#
# A HTML5 web browser with WebInspector support

require 'JS/html5'
require './inspector'


class WebToolbar < Gtk::Toolbar

    def initialize(browser)
        super()
        
        @browser = browser

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

        # scale other content besides from text as well
        @browser.set_full_content_zoom(true)

        @browser.signal_connect("title-changed") do |o| _title_changed_cb(*o) end
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
        @browser.open(entry.text)
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

    def initialize
        super
        settings = get_settings()
        settings.set_property("enable-developer-extras", true)
    end
end

class WebStatusBar < Gtk::Statusbar

    def initialize
        super
        @iconbox = Gtk::EventBox.new()
        @iconbox.add(Gtk::Image.new(Gtk::Stock::INFO,
                                                  Gtk::IconSize::BUTTON))
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

class WebBrowser < Gtk::Window
    def initialize
        super

        # logging.debug("initializing web browser window")

        @loading = false
        @browser= BrowserPage.new()
        @browser.signal_connect('load-started') do |o| _loading_start_cb(*o)  end
        @browser.signal_connect('load-progress-changed') do |o|
                                _loading_progress_cb(*o) 
                              end
        @browser.signal_connect('load-finished') do |o| _loading_stop_cb(*o)  end
        @browser.signal_connect("title-changed") do |o| _title_changed_cb(*o)  end
        @browser.signal_connect("hovering-over-link") do |o| _hover_link_cb(*o)  end
        @browser.signal_connect("status-bar-text-changed") do |o| _statusbar_text_changed_cb(*o)  end
        @browser.signal_connect("icon-loaded") do |o| _icon_loaded_cb end
        @browser.signal_connect("selection-changed") do |o| _selection_changed_cb(*o)  end
        @browser.signal_connect("set-scroll-adjustments") do |o| 
                                _set_scroll_adjustments_cb(*o)  
                              end
        @browser.signal_connect("populate-popup") do |o| _populate_popup(*o)  end

        @browser.signal_connect("console-message") do |o| _javascript_console_message_cb(*o) end
        @browser.signal_connect("script-alert") do |o| _javascript_script_alert_cb(*o)  end
        @browser.signal_connect("script-confirm") do |o| _javascript_script_confirm_cb(*o)  end
        @browser.signal_connect("script-prompt") do |o| _javascript_script_prompt_cb(*o)  end

        @inspector = Inspector.new(@browser.get_inspector())

        @dock = Gtk::Frame.new
        @inspector.set_dock @dock

        @scrolled_window = Gtk::ScrolledWindow.new()
        @scrolled_window.hscrollbar_policy = Gtk::POLICY_AUTOMATIC
        @scrolled_window.vscrollbar_policy = Gtk::POLICY_AUTOMATIC
        @scrolled_window.add(@browser)
        @scrolled_window.show_all()

        @toolbar = WebToolbar.new(@browser)

        @statusbar = WebStatusBar.new()

        vbox = Gtk::VBox.new()
        vbox.pack_start(@toolbar, expand=false, fill=false)
        vbox.pack_start(@scrolled_window,true,true)
        vbox.pack_start(@dock,true,true)
        vbox.pack_end(@statusbar, expand=false, fill=false)

        add(vbox)
        set_default_size(600, 480)

        signal_connect('destroy') do  Gtk.main_quit end

        about = """
<html><head><title>About</title></head><body>
<h1>Welcome to <code>browser_demo.rb</code></h1>
<p><a href=\"http://github.com/ppibburr/ruby_js\">Homepage</a></p>
</body></html>
"""
        @browser.load_string(about, "text/html", "iso-8859-15", "about:")

        show_all()
    end
    
    def show_all
      super
      @dock.hide()
    end
    
    def _loading_start_cb(view, frame)
        main_frame = @browser.get_main_frame()
        if frame == main_frame
            set_title("loading " + (frame.get_title().to_s + " " +
                                                    frame.get_uri().to_s))
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
        @statusbar.display(progress.to_s)
    end
    
    def _title_changed_cb( widget, frame, title)
         set_title(title)
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
    
    def _icon_loaded_cb(*o)
        print "icon loaded"
    end
    
    def _selection_changed_cb(*o)
        print "selection changed"
    end
    
    def _set_scroll_adjustments_cb( view, hadjustment=nil, vadjustment=nil)
        if hadjustment and vadjustment
            print "horizontal adjustment: %d", hadjustment.value
            print "vertical adjustmnet: %d", vadjustment.value
        end
    end
    
    def _navigation_requested_cb( view, frame, networkRequest)
        return 1
    end
    
    def _javascript_console_message_cb(view, message, line, sourceid)
        @statusbar.show_javascript_info()
    end
    
    def _javascript_script_alert_cb( view, frame, message)
        pass
    end
    
    def _javascript_script_confirm_cb( view, frame, message, isConfirmed)
        pass
    end
    
    def _javascript_script_prompt_cb( view, frame,
                                     message, default, text)
        pass
    end

    def _populate_popup( view, menu)
        aboutitem = Gtk::MenuItem.new(label="About RubyJS")
        menu.append(aboutitem)
        aboutitem.signal_connect('activate') do |o| _about_pywebkitgtk_cb(*o) end
        menu.show_all()
    end
    
    def _about_pywebkitgtk_cb(widget)
        @browser.open("http://github.com/ppibburr/ruby_js")

    end
end

    webbrowser = WebBrowser.new()
    Gtk.main()
