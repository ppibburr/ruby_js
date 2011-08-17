
#       test_from_ruby.rb
             
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
test = []

ctx = JS::GlobalContext.new(nil)

def test_method this,*o
  o.reverse
end

obj = JS::Object.new ctx,{
  :propA => 1,
  :propB => 'two',
  # This is JS::Object.from_ruby(ctx,(aMethod || aProc))
  # terse context construct
  :testArrayFunc => JS::Object.new(ctx) do |this,object|
    object[0]
  end,
  # This is JS::Object.from_ruby(ctx,(aMethod || aProc))
  # object inherits context
  :testHashFunc => proc do |this,object|
    object['testProp']
  end,
  # This is JS::Object.from_ruby(ctx,(aMethod || aProc))
  # pass method inherit context
  :testMethodFunc => self.method(:test_method)
}

test << obj['testArrayFunc'].is_function
test << obj['testHashFunc'].is_function
test << obj['testMethodFunc'].is_function
test << (obj['propA'] == 1.0)

obj1 = JS::Object.new ctx,[
  1,
  'two',
  obj
]

test << (obj1[1] == "two")

test << (obj['testArrayFunc'].call([
  1,
  2,
  3
]) == 1.0)

test << (obj['testHashFunc'].call({
  :testProp => 'aString'
}) == 'aString')

test << (obj['testMethodFunc'].call(0,1,2,3)[0] == 3)




if idx=test.index(false)
  puts "#{File.basename(__FILE__)} test #{idx} failed."
else
  puts "#{File.basename(__FILE__)} all tests passed."
end
