require File.join(File.dirname(__FILE__),'..','lib','JS','base')
require 'gtk2'

ctx = JS::GlobalContext.new(nil)
globj = ctx.get_global_object
globj.Ruby = Object.new
globj.Gtk = Gtk
globj.GLib = GLib
globj.GObject = GLib::Object
JS.execute_script ctx,<<EOJS
	w=Gtk.const_get('Window').new();

	w.signal_connect('expose-event',function(){
	  Gtk.main_quit();
	});

	w.signal_connect('delete-event',function() {
	  Gtk.main_quit();
	});

	w.show_all();

	Gtk.main();
EOJS
