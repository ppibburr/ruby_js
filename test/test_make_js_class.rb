require 'rubygems'
require 'gir_ffi'
require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')

ctx = JS::GlobalContext.new(nil)
# see JS/js_class_definition.rb for info about the struct
defi = JS::ClassDefinition.new
defi[:version] = 0 # must be set
defi[:className] = FFI::MemoryPointer.from_string("MyClass")

defi[:getProperty] = proc do |ct,obj,name,err|
  n = JS.read_string(name,false) # the false tells it not to release the jsstringref
  if n == "foo"
    # ... code .... (we'll return 'bar' since we're intercepting 'foo')
    JS::Value.from_ruby(ct,'bar').pointer
  else
    nil
  end
end

# ^|^ important to set up the definition before making class from it
klass = JS::Lib.JSClassCreate(defi)

obj = JS::Object.make(ctx,klass,nil)
obj['someProp'] = 3

test = [
  [
    obj['foo'],              # should not go up the chain and return 'bar'
    obj['noneSuch'],         # should go up the chain and return :undefined
    obj['someProp']          # should go up the chain and return 3.0
  ] == ["bar",:undefined,3.0]
]

ct = JS::Object.make_constructor(ctx,klass,nil)
ctx.get_global_object['MyObject'] = ct
r = JS.execute_script ctx,"""
  a=new MyObject();
  a['someProp'] = 3;
  ary = [];
  ary.push(a.foo);                // 'bar'
  ary.push(a.noneSuch);           // undefined
  ary.push(a.someProp);           // 3.0
  ary.push(a instanceof MyObject);// true 
  ary;
"""
test << r.map == ["bar",:undefined,3.0,true]

if idx=test.index(false)
  puts "#{File.basename(__FILE__)} test #{idx} failed."
  exit(1)
end

puts "#{File.basename(__FILE__)} all tests passed."
