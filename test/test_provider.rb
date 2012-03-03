require File.join(File.dirname(__FILE__),'..','lib','JS','html5')
p Gtk::Window.method(:new).arity
w = Gtk::Window.new
v = WebKit::WebView.new
v.load_html_string("<html><body></body></html>",'')

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |v,f|
  if v.get_main_frame.is_a?(WebKit::WebFrame)
    puts "all tests passed"
    Gtk.main_quit
  else
    puts "#{File.basename(__FILE__)} test 1 failed"
    Gtk.main_quit
    exit(1)
  end
end 

w.show_all

Gtk.main
