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
