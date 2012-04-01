RubyJS
===
    RubyJS is a library that uses FFI to provide bindings to JavaScript and WebKit from libwebkitgtk-1.0 (WebKit)
    allowing Full access to JavaScript and any JavaScript library

    This library enables ruby scripts to create JS objects, call functions, get/set properties, create callbacks. 
    As well, JavaScript scripts can call ruby methods, access objects.

    This is the core package in a suite of planned ruby_js packages
      core        (non-HtmlDOM)
      html5       (HtmlDOM in a WebKit::WebView)
      enviroment  (Desktop HTML5 Application develoment library (Gtk2))

![ExtJS from ruby](http://i1263.photobucket.com/albums/ii631/ppibburr/rubyjs_extjs.png)

Example
---
``` ruby
require 'rubygems'
require 'JS/base'
ctx = JS::GlobalContext.new(nil)
obj = JS::Object.new(ctx,{:name=>'World',:sayHello=> proc do |t,n| "hello #{n}" end})
p a = JS.execute_script(ctx,'this.sayHello(this.name);',obj) #=> "hello World"
p a == obj.sayHello(obj.name) #=> true
```
``` ruby
require 'JS/base'
require 'gtk2'

ctx = JS::GlobalContext.new(nil)
globj = ctx.get_global_object
globj.Ruby = Object.new
globj.Gtk = Gtk
globj.GLib = GLib
globj.GObject = GLib::Object
JS.execute_script ctx,<<EOJS
	w=Gtk.const_get('Window').new();

	w.signal_connect('show',function(){
	  Ruby.send('puts','shown');
	});

	w.signal_connect('delete-event',function() {
	  Gtk.main_quit();
	});

	w.show_all();

	Gtk.main();
EOJS
```

Getting Started
---
  Required:
  ---
    1. Gtk2, either the gem, distro package or some typelib information for GirFFI (gem i gir_ffi)
    2. rake
  
  Install:
  ---
  default:  rake gem # may need to be root

  optional: rake unbuild
            rake build
            rake test # make sure everything works
            rake gem
    

Samples
---

Check the "samples" folder for examples on how to utilise this library

Contributors
---
* Matt Mesanko (ppibburr)

License
---
Copyright (c) 2011-2012 Matt Mesanko.
MIT license see LICENSE.
