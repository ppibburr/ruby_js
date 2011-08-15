require 'rubygems'
require 'gir_ffi'

require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')

test = []

ctx = JS::GlobalContext.new(nil)

obj = JS::Object.new(ctx,{
  :jary => [1,2,3,nil,:undefined,true,"aString",{:foo=>"bar"}]
})
obj['testProperty'] = 1.8
obj['testProperty1'] = "true"

a = []
obj.each do |prop|
  a << obj.hasOwnProperty.call(prop)
end

test << !a.index(false)

a = []
obj.each_pair do |name,q|
  a << [name,q]
end

test << !!a.find do |q| q[0] == "testProperty" and q[1] == 1.8 end

test << (len=obj.jary.length) == 8
test << obj.jary[0] == 1
test << obj.jary[(len-1)].foo == "bar"

len_map = obj.jary.map.call do |this,item,i,q|
  
end.length

test << len == len_map

idx = test.index false
fail("#{File.basename(__FILE__)} test #{idx} failed") if idx
puts "#{File.basename(__FILE__)} all tests passed"


