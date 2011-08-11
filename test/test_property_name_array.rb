require 'rubygems'
require 'gir_ffi'
require File.join(File.dirname(__FILE__),'..','lib','JS')

ctx = JS::GlobalContext.new(nil)
obj = JS::Object.new(ctx)
names = ['foo','bar','baz','moof']
names.each_with_index do |n,i|
  obj[n] = "property #{i}"
end

p obj.copy_property_names.get_count == names.count

p obj.properties == names

p obj.properties[2] == 'baz'
p 'baz' == obj.copy_property_names.get_name_at_index(2)

obj['myFunc'] = JS::Object.make_function_with_callback(ctx,'myFun') do
  true
end

p obj.functions == ['myFunc']
