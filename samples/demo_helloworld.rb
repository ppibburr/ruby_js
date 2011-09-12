if __FILE__ == $0
  require 'demo'
end

def run_demo_hello
  parent = DemoRunner.get_target(__FILE__)
  size = [600,400]
  size = [-1,-1] if __FILE__ != $0
  wi = Rwt::Dow.new(parent,"HelloWorld",:size=>size)
  wi.add b=Rwt::Button.new(wi,"Click me ...",:position=>[275,170])

  b.collection!.bind(:click) do
    b.element.context.get_global_object.alert("Hello World")
  end

  if __FILE__ == $0
    wi.show
  else
    parent.add wi
  end
end

if __FILE__ == $0
  DemoRunner.run_standalone_demo(method(:run_demo_hello))
else
  run_demo_hello
end
