require 'rubygems'
require 'gir_ffi'
require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')
require File.join(File.dirname(__FILE__),'..','lib','JS','ruby_object')

ctx = JS::GlobalContext.new(nil)

obj=JS::RubyObject.new(ctx)
obj.context=ctx
obj.object = File
obj

ctx.get_global_object['File'] = obj
fail("#{File.basename(__FILE__)} test 1 failed") unless JS.execute_script(ctx,"File.read('#{__FILE__}');") == File.read(__FILE__)
puts "#{File.basename(__FILE__)} all test passed."
