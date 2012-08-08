=begin
  *
    Sample code implementing and demonstrating the uses of the patches
    in subclass_normailze.rb
  *
=end

require 'rubygems'
require 'ffi-gtk3'
require './subclass_normalize'

GirFFI.setup :WebKit, '3.0'

class MyView < WebKit::WebView
  def initialize a,b
    super()
  end
end

class MyVBox < Gtk::VBox
  # take no arguments
  def initialize
    # super with args
    super false,0
  end
end

class MyWindow < Gtk::Window
  # take no arguments
  def initialize
    # super with args
    super :toplevel
    
    # the call to add here would otherwise fail becuase @struct would be nil
    add vb = MyVBox.new()           # would otherwise fail, Gtk::VBox.new expects 2 arguments
    vb.add wv = MyView.new(1,:foo)  #                       WebKit::WebView.new expects 0 arguments
    
    wv.signal_connect("load-started") do |i_am_wv, web_frame|
      p i_am_wv == wv
    end

    wv.open('http://www.google.com/')
    
    show_all()


    signal_connect("destroy") { |*o|
      Gtk.main_quit
    }

  end
end

Gtk.init

win = MyWindow.new       # would otherwise fail, expects 1 argument

Gtk.main()
