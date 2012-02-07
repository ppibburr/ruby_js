
#       test_enumeration.rb
             
#		(The MIT License)
#
#        Copyright 2011 Matt Mesanko <tulnor@linuxwaves.com>
#
#		Permission is hereby granted, free of charge, to any person obtaining
#		a copy of this software and associated documentation files (the
#		'Software'), to deal in the Software without restriction, including
#		without limitation the rights to use, copy, modify, merge, publish,
#		distribute, sublicense, and/or sell copies of the Software, and to
#		permit persons to whom the Software is furnished to do so, subject to
#		the following conditions:
#
#		The above copyright notice and this permission notice shall be
#		included in all copies or substantial portions of the Software.
#
#		THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
#		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
require 'rubygems'
require 'gir_ffi'

require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')

test = []

ctx = JS::GlobalContext.new(nil)
JS::Object.new(ctx,[1,2])
obj = JS::Object.new(ctx,{
  :jary => [1,2,3,nil,:undefined,true,"aString",JS::Object.new(ctx,{:foo=>"bar",:baz=>[1,2]})]
})
obj['testProperty'] = 1.8
obj['testProperty1'] = "true"

a = []
obj.each do |prop|
  a << obj.hasOwnProperty(prop)
end

test << !a.index(false)

a = []
obj.each_pair do |name,q|
  a << [name,q]
end

test << !!a.find do |q| q[0] == "testProperty" and q[1] == 1.8 end

test << ((len=obj.jary.length) == 8)
test << (obj.jary[0] == 1)
#test << (obj.jary[(len-1)].foo == "bar")
p obj.jary.has_property("7")
p obj.jary["7"]
len_map = obj.jary.map do |q|
  
end.length

test << len == len_map

obj.jary.each_with_index do |q,i|

end

idx = test.index false
fail("#{File.basename(__FILE__)} test #{idx} failed") if idx
puts "#{File.basename(__FILE__)} all tests passed"


