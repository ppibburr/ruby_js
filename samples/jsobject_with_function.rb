require 'rubygems'
require 'JS/base'
ctx = JS::GlobalContext.new(nil)
obj = JS::Object.new(ctx,{:name=>'World',:sayHello=> proc do |t,n| "hello #{n}" end})
p a = JS.execute_script(ctx,'this.sayHello(this.name);',obj) #=> "hello World"
p a == obj.sayHello(obj.name) #=> true

