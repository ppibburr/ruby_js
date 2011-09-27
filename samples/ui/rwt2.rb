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
  require 'rwt-shift-box'
  require 'rwt-book'
  require 'rwt-resizable'
  require 'rwt-draggable'
  require 'rwt-expandable'
  require 'rwt-controls2'
  require 'rwt-button'
end
