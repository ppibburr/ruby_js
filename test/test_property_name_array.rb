require 'rubygems'
require 'gir_ffi'
require File.join(File.dirname(__FILE__),'..','lib','JS')

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

if idx=[
  obj.copy_property_names.get_count == names.count,
  obj.properties == names,
  obj.properties[2] == 'baz',
  'baz' == obj.copy_property_names.get_name_at_index(2),
  obj.functions == ['myFunc']
].index(false) then
  puts "#{File.basename(__FILE__)} test #{idx} failed"
  exit(1)
else
  puts "#{File.basename(__FILE__)} all passed"
end
