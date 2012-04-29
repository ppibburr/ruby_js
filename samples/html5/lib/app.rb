require File.join(File.dirname(__FILE__),'html5')
module RubyJS
  class App
    HTML = "<html><body></body></html>"
    attr_reader :shell,:vbox,:view,:top_child
    def initialize html=HTML,base_uri=nil
      @shell = Gtk::Window.new :toplevel
      @vbox = Gtk::VBox.new false,0
      @top_child = Gtk::VBox.new false,0
      @view = WebKit::WebView.new
      
      @html = html
      @base_uri = base_uri
      sw = Gtk::ScrolledWindow.new nil,nil
      sw.add view
      vbox.pack_start top_child,false,true,0
      vbox.pack_start sw,true,true,0    
      
      shell.add vbox
      
      shell.set_size_request 400,440
      shell.signal_connect "delete-event" do
        on_exit
      end   
      
      view.signal_connect "populate-popup" do |*o|
        show_popup o[1]
      end
      
      view.signal_connect "load-finished" do |*o|
        (@_onload_cb||proc do |*o| true  end).call *o
      end
    end
    
    def show_popup menu
  	  items = menu.children
	  case q=items[0].get_label.gsub(/^\_/,'')
	  when /^Back/
	    # navigation
	    navigate_menu(menu)
	  when /^Cut/
	    # edit menu
	    edit_menu(menu)
  	  when /^Open Link/
	    # /link menu/
	    link_menu(menu)
	  when /^Open \_Image/
        image_menu(menu)
      when /^Copy/
        copy_menu(menu)
	  else
	  end
    end
    
    def global_object
      view.get_main_frame.global_object
    end
    
    def on_exit
      Gtk.main_quit
    end
    
    def exit
      on_exit
    end
    
    def display
      view.load_html_string @html,@base_uri    
    end
    
    def run &b
      b.call self
      shell.show_all
      Gtk.main
    end
    
    def self.run &b
      Gtk.init []
      app = self.new
      app.run &b
      return app
    end
    
    def navigate_menu menu
      menu.children.each do |c|
        c.destroy
      end
    end
    
    def link_menu menu
      menu.children.each do |c|
        label = c.get_label.gsub(/^\_/,'')
        c.destroy unless label =~ /Copy Link/ || label =~ /Download/
      end
      menu.append i=Gtk::MenuItem.new()
      i.set_label "Open With"
      i.show
      i.signal_connect "activate" do
        global_object.alert("Foo")
      end    
    end
    
    def edit_menu menu
    end
    
    def copy_menu menu
    end
    
    def image_menu menu
      menu.children[0].destroy
    end
    
    def onload &b
      @_onload_cb = b
    end
    
    def preload &b
      view.signal_connect "load-started" do
        b.call view.get_main_frame.get_global_object
      end
    end
  end
end

if __FILE__ == $0
	RubyJS::App.run do |app|
	  app.onload do |*o|
	  app.preload do |a|
	  
	  end
		app.global_object.alert("Hello World")
	  end
	  app.display
	end
end
