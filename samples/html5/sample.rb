require 'JS/html5/app'
      
class App < RubyJS::App
  body = "<body><div id=b1 class=button>click me</div></body>"
  HTML = RubyJS::App::HTML.gsub(/\<body\>.*\<\/body\>/,body)
  
  def on_ready *o
    xui("#b1").on "click" do
	  alert 1
	end
  end
end

app = App.run
