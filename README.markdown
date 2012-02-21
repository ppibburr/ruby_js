RubyJS
===
    RubyJS is a library that uses FFI to provide bindings to JavaScript and WebKit from libwebkitgtk-1.0 (WebKit)
    allowing Full access to JavaScript and any JavaScript library
    as well as full WebKit api access. 

    This library enables ruby scripts to create JS objects, call functions, get/set properties, create callbacks. 
    As well, JavaScript scripts can call ruby methods, access objects.

    Using Gtk2 you can embed a WebKit::WebView and develop HTML5 desktop applications 

    JS/base         core JavaScript bindings
    JS/html5        webkit webview support (pulls in Gtk2 and WebKit if WebKit is not defined,
                          looks for standard Gtk2 and pulls in JS/webkit_ffi
                          falls back to GirFFI for Gtk2 and pulls in JS/webkit_gir_ffi
                        to manually select a a webkit binding, "require JS/webkit_[ffi|gir_ffi]"
                          before requiring)
                        
    JS/application  library to ease the interaction with the (JavaScript)DOM from a WebKit::WebView (pulls in JS/html5)

    RubyJS works with full features with standard* Gtk2 as well as Gtk2 provided by GirFFI**

    *  JavaScript binding access to the DOM and WebKit api
    ** when using GirFFI both the JavaScript bindings and GObject bindings to the DOM are accessible (WebKitDOM api)

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
```
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
```

Getting Started
---
  Required:
  ---
    1. Gtk2, either the gem, distro package or some typelib information for GirFFI (gem i gir_ffi)
    2. rake
  
  Install:
  ---
    1. rake build (optional, unless modifying source files)
    2. rake gem (may require super user privilages, as it will install the gem)


Samples
---
    JavaScript usage
    HTML5 DOM access
    A WebBrowser

Check the "samples" folder for examples on how to utilise this library

Contributors
---
* Matt Mesanko (ppibburr)

License
---
Copyright (c) 2011-2012 Matt Mesanko.
MIT license see LICENSE.
