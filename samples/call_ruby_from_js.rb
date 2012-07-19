require File.join(File.dirname(__FILE__),'..','lib','JS','base')
require 'gtk2'

ctx = JS::GlobalContext.new(nil)
globj = ctx.get_global_object
globj.Ruby = Object
globj.Gtk = Gtk
globj.GLib = GLib
globj.GObject = GLib::Object
JS.execute_script ctx,<<EOJS
	w=Gtk.Window.new();

	w.signal_connect('show',function(){
	  Ruby.puts('shown');
	});

	w.signal_connect('delete-event',function() {
	  Gtk.main_quit();
	});

	w.show_all();
    cnt = 0;
    GLib.Idle.add(200,function() {
      d = Ruby.p('js');
      cnt++;
      return cnt < 3 ? true : false;
    });

	Gtk.main();
EOJS
