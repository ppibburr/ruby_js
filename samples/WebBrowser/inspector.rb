# inspector.rb
# Ported from pywebkitgtk/source/browse/trunk/demos/inspector.py
#
# Handle the display of WebInspector from a WebKit::WebView

class Inspector < Gtk::Window
    def initialize inspector
        super()
        
        set_size_request 600,400
        
        @_web_inspector = inspector

        @_web_inspector.signal_connect("inspect-web-view") do |o|
		  _inspect_web_view_cb(*o)
		end
		
        @_web_inspector.signal_connect("show-window") do |o|
	   	  _show_window_cb(*o)
	    end
        
        @_web_inspector.signal_connect("attach-window") do |o|
          _attach_window_cb(*o)
        end
        
        @_web_inspector.signal_connect("detach-window") do |o|
          _detach_window_cb(*o)
        end
        
        @_web_inspector.signal_connect("close-window") do |o|
          _close_window_cb(*o)
        end
        
        @_web_inspector.signal_connect("finished") do |o|
		  _finished_cb(*o)
		end

        signal_connect("delete-event") do |o| _close_window_cb(*o) end
    end
    
    def set_dock widget
      @dock_widget = widget
    end
    
    def _inspect_web_view_cb(inspector, web_view)
        """Called when the 'inspect' menu item is activated"""
        if !@scrolled_window
			@scrolled_window = Gtk::ScrolledWindow.new()
			@scrolled_window.hscrollbar_policy = Gtk::POLICY_AUTOMATIC
			@scrolled_window.vscrollbar_policy = Gtk::POLICY_AUTOMATIC
			webview = WebKit::WebView.new()
			@scrolled_window.add(webview)
			@scrolled_window.show_all()
		  
			@docked = false
		  
			add(@scrolled_window)
		end
        return @scrolled_window.children[0]
    end
    
    def _show_window_cb( inspector)
        """Called when the inspector window should be displayed"""
        if @docked
          @scrolled_window.reparent self
          @dock_widget.hide()
        end
        present()
        return true
    end
    
    def _attach_window_cb ( inspector)
        """Called when the inspector should displayed in the same
        window as the WebView being inspected
        """
        @scrolled_window.reparent @dock_widget
        @dock_widget.show
        @docked = true
        hide()
        return true
    end
    
    def _detach_window_cb (inspector)
        """Called when the inspector should appear in a separate window"""
        @scrolled_window.reparent self
        @dock_widget.hide()
        @docked=false
        show()
        return true
    end
    
    def _close_window_cb ( inspector, web_view = nil)
        """Called when the inspector window should be closed"""
        print "close"
        @dock_widget.hide if @docked
        hide()
        return true
    end
    
    def _finished_cb ( inspector)
        """Called when inspection is done"""
        print "finished"
        @_web_inspector = 0
        destroy()
        return false
    end
end
