__run__ = nil
if __FILE__ == $0
  require 'JS/application'
  __run__ = true
end

class View < WebKit::WebView
  SIGNALS = [
	  "close-web-view"                                 ,
	  "console-message"                                ,
	  "copy-clipboard"                                 ,
	  "create-plugin-widget"                           ,
	  "create-web-view"                                ,
	  "cut-clipboard"                                  ,
	  "database-quota-exceeded"                        ,
	  "document-load-finished"                         ,
	  "download-requested"                             ,
	  "editing-began"                                  ,
	  "editing-ended"                                  ,
	  "frame-created"                                  ,
	  "geolocation-policy-decision-cancelled"          ,
	  "geolocation-policy-decision-requested"          ,
	  "hovering-over-link"                             ,
	  "icon-loaded"                                    ,
	  "load-committed"                                 ,
	  "load-error"                                     ,
	  "load-finished"                                  ,
	  "load-progress-changed"                          ,
	  "load-started"                                   ,
	  "mime-type-policy-decision-requested"           , 
	  "move-cursor"                                  ,  
	  "navigation-policy-decision-requested"        ,   
	  "navigation-requested"                       ,    
	  "new-window-policy-decision-requested"      ,     
	  "onload-event"                             ,      
	  "paste-clipboard"                         ,       
	  "populate-popup"                         ,        
	  "print-requested"                       ,         
	  "redo"                                 ,          
	  "resource-request-starting"           ,           
	  "script-alert"                       ,            
	  "script-confirm"                    ,             
	  "script-prompt"                    ,              
	  "select-all"                      ,               
	  "selection-changed"              ,                
	  "should-apply-style"            ,                 
	  "should-begin-editing"         ,                  
	  "should-change-selected-range",                   
	  "should-delete-range"  ,                          
	  "should-end-editing"  ,                           
	  "should-insert-node"   ,                          
	  "should-insert-text"    ,                         
	  "should-show-delete-interface-for-element"      , 
	  "status-bar-text-changed"     ,                   
	  "title-changed"    ,                              
	  "undo"   ,                                        
	  "user-changed-contents"  ,                        
	  "viewport-attributes-changed",                    
	  "viewport-attributes-recompute-requested",        
	  "web-view-ready" ,                                
	  "window-object-cleared",     
    ]
	def initialize()
		super()
		p self.class.signals.sort
		settings = get_settings()
		settings.set_property("enable-developer-extras", true)
		signal_connect "window-object-cleared" do |o|
		  p o
		end
	end
	
	def connect_signals(obj)
		self.class::SIGNALS.each do |s|
		  if obj.respond_to?(m=s.gsub("-","_"))
		    signal_connect s do |o|
		      obj.send(m.to_sym,*o)
		    end
		  end
		end	
	end
end

if __run__
  w = Gtk::Window.new
  w.add v=View.new
  v.load_html_string "foo",nil
  v.signal_connect "property-notify-event" do |o|
    p o
  end
  w.show_all
  w.signal_connect "delete-event" do
    Gtk.main_quit
  end
  Gtk.main
end
