begin
  require "JS"
rescue LoadError
  require 'rubygems'
  require 'JS'
end

require "JS/webkit"
require "JS/props2methods"

module Rwt
  require 'rwt-ui'
  require 'rwt-core'
  require 'rwt-box'
  require 'rwt-resizable'
  require 'rwt-draggable'
  require 'rwt-expandable'
  require 'rwt-controls'
end
