require 'JS/application'

class MyApp < JS::Application
  HTML_TEMPLATE = """<html><head><script type='text/javascript'>
var Foo = {
  create: function(copy) {
    var o=new Object();
    no = Object.apply(o,[copy]);
    return no;
  }
};
</script></head><body></body></html>"
	module MyRunner
		def on_render
      alert Foo.create({
        :bar => "foobar"
      }).bar
    end
	end
	
	def on_render
		JS::Application.provide(context) do	
			use_runner MyRunner
			build_lib "Foo"
		end.run
	end
end

MyApp.new.run





    
