require File.join(File.dirname(__FILE__),'lib','app')
class App < RubyJS::App
  def initialize *o
    super
    onload do
      body = global_object.document.body
      body.innerText = "Hello World"
      body.onclick = method(:click)
    end
  end
  
  def click target,event
    global_object.alert([target,event])
  end
end

App.run do |app| 
  app.display
end
