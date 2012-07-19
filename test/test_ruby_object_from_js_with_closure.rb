require File.join(File.dirname(__FILE__),'..','lib','JS','base')

class Foo
  attr_reader :name
  def initialize n="aFoo"
    @name = n
  end
  def pass_block q, r=3, &b
    out = []
    [1.0,5.0,8.0].each do |i|
      out << b.call((i*q)/r)
    end 
    return out
  end
end

ctx = JS::GlobalContext.new(nil)
globj = ctx.get_global_object
globj.Ruby = Object

val = JS.execute_script ctx,<<EOJS
	obj = Ruby.const_get('Foo').new('bar');
	obj.pass_block(1,function(arg1) {
	  return arg1 + 1;
	});
EOJS
globj['foo'] = method(:p)
globj.foo 11
if (val.map do |f| f.floor end) == [1,2,3]
  puts "test :#{__FILE__}; passed" 
else
  fail("Test Failed.")
end
