require 'rubygems'
require 'gir_ffi'
require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')
ctx = JS::GlobalContext.new(nil)
obj = JS::Object.new(ctx)
names = ['foo','bar','baz','moof']

names.each_with_index do |n,i|
  obj[n] = "property #{i}"
end

names << 'myFunc'

obj['myFunc'] = JS::Object.make_function_with_callback(ctx,'myFun') do
  true
end

if idx=[obj.foo == "property 0",
  obj.myFunc.is_function,
  obj.my_func.is_function
].index(false) then
  puts "#{__FILE__} test #{idx} failed"
  exit(1)
else
  puts "#{__FILE__} all passed"
end  
