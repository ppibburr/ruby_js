class Browser < Gtk::Window
  def new_window_policy_decision_requested view,frame,request,nav_act,pol_dec
    false
  end
  
  def create_web_view view,frame
    create_page().view
  end
  
  def web_view_ready view
    @view_book.set_page_by_view view
  end
  
  def load_finished view,frame
        p frame
    @toolbar.set_loading false if get_active_view == view
  end
  
  def load_started view,frame
    @toolbar.set_loading true if get_active_view == view
  end
  
  def load_error view,frame,uri, error
  
  end
  
  def load_committed view,frame
    puts "load committed"
  end
  
  def hovering_over_link view,title,uri
    text = ''
    p title;p uri
    if uri
      text = uri
    end

    @statusbar.display(text) 
  end
  
  def statusbar_text_changed( view, text)
    @statusbar.display(text)
  end
  
  def download_requested view,dl
    return DownloadDialog.new(view,dl).run(self)
  end
  
  def mime_type_policy_decision_requested view,frame,request,type,pol_dec
	if get_active_view.can_show_mime_type(type)
		return false
	else
		pol_dec.download
		return true
	end
  end
  
  def navigation_policy_decision_requested view,frame,request,nav_act,pol_dec
    false
  end
  
  def onload_event view,frame
    puts "onload"
  end
  
  def icon_loaded view,uri
     if view == get_active_page.view
       @toolbar.set_location_icon get_icon(uri)
     end
     
     pg = @view_book.get_page_by_view view
     @view_book.set_tab_icon pg,get_icon(uri)
  end

  def title_changed view,frame,title
     if view == get_active_page.view
       set_title title
     end
     
     pg = @view_book.get_page_by_view view
     @view_book.set_tab_text pg,title
  end

  def console_message view,message,line,source
    puts ""
    puts source
    puts line
    puts message
  end
  
  def window_object_cleared view,frame,context,object

  end
  
  def populate_popup view,menu
    if view.has_selection
      sel = view.get_window_object.getSelection.toString.strip
      if !sel.empty?
        if sel =~ REGEXP[:is_protocol]
          menu.append item = Gtk::MenuItem.new("GoTo #{sel}")
          item.signal_connect "activate" do
            view.get_main_frame.load_uri("#{sel}")
          end 
        else
          menu.append item = Gtk::MenuItem.new("Search for #{sel}")
          item.signal_connect "activate" do
            view.load_uri("http://google.com/search?q=#{sel}")
          end
        end
      end
    end
    menu.append about = Gtk::MenuItem.new("About Browser.rb")
    about.signal_connect('activate') do
      on_about(view)
    end
    menu.show_all()
    false
  end
end
