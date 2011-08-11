require "rubygems"
require "ffi"
module JS
  require File.join(File.dirname(__FILE__),'JS','ffi','lib')
  require File.join(File.dirname(__FILE__),'JS','Object')
  require File.join(File.dirname(__FILE__),'JS','Value')
  require File.join(File.dirname(__FILE__),'JS','Context')
  require File.join(File.dirname(__FILE__),'JS','GlobalContext')
  require File.join(File.dirname(__FILE__),'JS','ContextGroup')
  require File.join(File.dirname(__FILE__),'JS','Value')
  require File.join(File.dirname(__FILE__),'JS','String')
  require File.join(File.dirname(__FILE__),'JS','PropertyNameArray')
  require File.join(File.dirname(__FILE__),'JS','js_hard_code')
  require File.join(File.dirname(__FILE__),'JS','webkit_hard_code')
end
