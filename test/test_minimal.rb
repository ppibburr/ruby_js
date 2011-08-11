
require 'rubygems'
require 'gir_ffi'
require File.join(File.dirname(__FILE__),'..','lib','JS')

def all_true ary
  val = 1
  ary.map do |q| n = 0; n = 1 if q; val = n * val end 
  return true if val == 1
  false
end

def find_failed(ary)
  tis = []
  ary.each_with_index do |v,i|
    tis << i if !v
  end
  tis.map do |i| i+1 end
end

ctx = JS::GlobalContext.new(nil)

gobj = ctx.get_global_object


my_obj = JS::Object.new(ctx)

ary = []

my_obj.set_property("testString",'aString')
ary << ('aString' == my_obj.get_property("testString"))
ary << (my_obj.copy_property_names.get_name_at_index(0) == "testString")
ary << (my_obj.copy_property_names.get_count == 1)

my_obj["testNumber"] = 1979.05
ary << (1979.05 == my_obj.get_property("testNumber"))

my_obj["testBool"] = true
ary << my_obj["testBool"]

my_obj["testUndefined"] = :undefined
ary << (:undefined == my_obj["testUndefined"])

my_obj.set_property("testNull",nil)
ary << !my_obj.get_property("testNull")

fun = JS::Object.make_function_with_callback(ctx,'sumOf') do |this,*args|
  sum = 0
  args.each do |a|
    sum = sum + a
  end
  
  sum # in jscript: return sum;
end

ary << (fun.is_function == true)

ary << (fun.call(1,2.98) == 3.98)

gobj.set_property('sumOf',fun)

val = JS.execute_script(ctx,"this.sumOf(1,2.98);")

ary << (val == 3.98)

if all_true(ary)
  puts "#{File.basename(__FILE__)} passed"
else
  puts "tests, #{find_failed(ary).join(",")} failed."
  exit(1)
end
