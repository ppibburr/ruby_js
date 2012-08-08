RubyJS
===
    RubyJS is a Ruby library that uses FFI to provide bindings to JavaScript and WebKit from libwebkitgtk (WebKit)
    allowing Full access to JavaScript and any JavaScript library and Full access from JavaScript to Ruby

    This library enables ruby scripts to create JS objects, call functions, get/set properties, create callbacks. 
    As well, JavaScript scripts can call ruby methods, access objects.

    The essential goal of this library is to provide means of creating HTML5 applications from within Ruby.
    Interestingly, Desktop applications can be wrote in JavaScript, by setting a RubyObject in a context
    see the samples directory

    Using this library you can write a desktop application that leverages full HTML5 features

    This is the core package in a suite of planned ruby_js packages
      core        (non-HtmlDOM)
      html5       (HtmlDOM in a WebKit::WebView)
      enviroment  (Desktop HTML5 Application develoment library (Gtk2))

![ExtJS from ruby](http://i1263.photobucket.com/albums/ii631/ppibburr/ss1.png)

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
	  Ruby.puts('shown');
	});

	w.signal_connect('delete-event',function() {
	  Gtk.main_quit();
	});

	w.show_all();

	Gtk.main();
EOJS
```
``` javascript
    // JavaScript file ran by: bin/run_js file.js
	Thread.new(function() {
	  p("i'm in a thread");
	});

	sleep(1);

	puts("OK! heres my source ...");
	puts(File.read(__FILE__));

	File.open("test.txt",'w',function(f) {
	 f.puts("tree");
	});

	puts("This is what i wrote to test.txt ...")
	puts(File.read("test.txt"));

	exit(0);
```

Getting Started
---
  Required:
  ---
    1. gir_ffi ~> 0.3.1 (system must meet its requirements)
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
