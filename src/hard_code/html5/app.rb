require File.join(File.dirname(__FILE__),'..','html5')
module RubyJS
  class App
    def self.file_rel_to path,rel=File.dirname(__FILE__)
      "file://#{File.expand_path(rel)}/#{path}"
    end
    
    HTML = "<html><head><link rel='stylesheet' type='text/css' href='#{file_rel_to('resource/styles.css')}'><script type='text/javascript' src='#{file_rel_to('resource/xui.js')}'></script></head><body><div class='button'>hi</div></body></html>"
    attr_reader :shell,:vbox,:view,:top_child
    def initialize html=HTML,base_uri="File://#{File.dirname(__FILE__)}"
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
      
      #p view.get_settings.set_property("enable-universal-access-from-file-uris",true)
      
      view.signal_connect "populate-popup" do |*o|
        show_popup o[1]
      end
      
      view.signal_connect "load-finished" do |*o|
        (@_onload_cb||proc do |*o| true  end).call *o
      end
      

      view.signal_connect "load-started" do
        global_object.handler = method(:on_ready)
      end
    end
    
    def global_object
      @global_object ||= view.get_main_frame.global_object
    end
    
    def xui *o,&b
      global_object["x$"].call(*o,&b)
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
    
    def on_exit
      Gtk.main_quit
    end
    
    def exit
      on_exit
    end
    
    def display
      view.load_html_string @html,@base_uri    
    end
    
    def run
      view.load_html_string(self.class::HTML,@base_uri)
      shell.show_all
      Gtk.main
    end
    
    def self.run
      Gtk.init []
      app = self.new
      app.run
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
      @on_preload_cb = b
    end
    
    def on_ready()
    end
    
    def method_missing m,*o,&b
      if global_object.has_property(m.to_s)
        if (prop=global_object[m]).is_function
          return prop.call(*o,&b)
        else
          return prop
        end
      end
      super
    rescue
      super
    end
  end
end

if __FILE__ == $0
    class App < RubyJS::App
      def on_ready(this)
        alert "hi"
        p document.documentElement.outerHTML
      end
	end
	App.run
end
