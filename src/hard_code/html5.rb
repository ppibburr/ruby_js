require File.join(File.dirname(__FILE__),'base')
if !const_defined?(:WebKit)
  require File.join(File.dirname(__FILE__),"webkit")
end
require File.join(File.dirname(__FILE__),"resource")
