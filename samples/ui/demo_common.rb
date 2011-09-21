def base document,idx
  root = Rwt::UI::Collection.new(document)
  document.body.innerHTML="<ul id=menu></ul><div id=test style=\"width:300px;height:300px;\"></div>" 
  menu = root.find(:menu).set_style('font-size','11px')[0]
  Examples.each_with_index do |e,i|
    o=Rwt::Drawable.new(menu,:size=>[1,20],:tag=>'li')
    o.style.width='400px'
    o.style.cursor='pointer'
    o.style.color='blue' unless idx==i+1
    o.set_style STYLE::BORDER if idx==i+1
    o.innerText = e
    o.show
    o.collection.on('click') do
      send "example#{i+1}",document
    end
  end
  
  return root,window = document.context.get_global_object.window
end 

def launch
  w = Gtk::Window.new
  v = WebKit::WebView.new
  w.set_size_request(1024,600)
  w.add v
  v.load_html_string "<html><body style='width:100%;'></body></html>",nil

  v.signal_connect('load-finished') do |o,f|
   example1 f.get_global_context.get_global_object.document
  end

  w.signal_connect("delete-event") do
   Gtk.main_quit
  end

  w.show_all

  Gtk.main
end
