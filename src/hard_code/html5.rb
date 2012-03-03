require File.join(File.dirname(__FILE__),'base')
if !defined?(WebKit)
  require File.join(File.dirname(__FILE__),"webkit")
  Gtk.init
end
require File.join(File.dirname(__FILE__),"resource")
