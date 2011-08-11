require 'rubygems'
require 'ffi'

require File.join(File.dirname(__FILE__),'lib','ast')
require File.join(File.dirname(__FILE__),'lib','iface')
require File.join(File.dirname(__FILE__),'lib','sugar')
require File.join(File.dirname(__FILE__),'lib','library')

def decamel s
  while s =~ /([a-z])([A-Z])/
    s = s.gsub($1+$2,"#{$1}_#{$2}")
  end
  return s.downcase
end
