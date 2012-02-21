class Browser < Gtk::Window
  def new_window_policy_decision_requested view,frame,request,nav_act,pol_dec
    false
  end
  
  def create_web_view view,frame
    create_page().view
  end
  
  def load_finished view,frame
    puts "load finished"
  end
  
  def load_started view,frame
    puts "load started"
  end
  
  def load_committed view,frame
    puts "load committed"
  end
  
  def hovering_over_link view,title,uri
    puts title
    puts uri
  end
  
  def download_requested view,dl
    puts "download"
  end
  
  def mime_type_policy_decision_requested view,frame,request,type,pol_dec
	if get_active_view.can_show_mime_type(type)
		return false
	else
		policy.download
		return true
	end
  end
  
  def navigation_policy_decision_requested view,frame,request,nav_act,pol_dec
    false
  end
  
  def onload_event view,frame
    puts "onload"
  end

  def console_message view,message,line,source
    puts ""
    puts source
    puts line
    puts message
  end
end
