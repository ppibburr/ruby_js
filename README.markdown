RubyJS
===
RubyJS is a library that uses FFI to provide bindings to JavaScriptCore from libwebkitgtk-1.0 (WebKit) allowing Full access to JavaScript and any JS library as well as some additional WebKit api access. This library enables ruby scripts to create JS objects, call functions, get/set properties, create callbacks. As well, JavaScript scripts can call ruby methods, access objects. Using Gtk2 you can write a whole ruby application utilizing Web Technologies, JavaScript Toolkits etc.

![ExtJS from ruby](http://i1263.photobucket.com/albums/ii631/ppibburr/rubyjs_extjs.png)

Example
---
    shell {
      text "Example"
      label {
        text "Hello World!"
      }
    }.open

Getting Started
---
1. Install Gtk2 (gem or distro package) **note: Gtk2 can be provided via FFI with the gir_ffi gem, TODO: make it easy to use the FFI provided Gtk2
2. checkout the rubyjs source
3. install rake (gem or distro package)
4. rake build
5. rake gem (may require super user privilages, as it will install the gem)
6. write a script with 'require "rubyjs/desktop"', this will pull in all functionality for writing applications
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
