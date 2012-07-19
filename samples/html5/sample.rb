require 'JS/html5/app'
      
class App < RubyJS::App
  body = <<-EOS
  <body><div id=b1 class=button>click me</div><br><br><!-- HTML generated using hilite.me --><div style="background: #ffffff; overflow:auto;width:auto;color:black;background:white;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><table><tr><td><pre style="margin: 0; line-height: 125%"> 1
 2
 3
 4
 5
 6
 7
 8
 9
10
11
12
13
14
15
16</pre></td><td><pre style="margin: 0; line-height: 125%"><span style="color: #007020">require</span> <span style="background-color: #fff0f0">&#39;JS/html5/app&#39;</span>
      
<span style="color: #008000; font-weight: bold">class</span> <span style="color: #B00060; font-weight: bold">App</span> <span style="color: #303030">&lt;</span> <span style="color: #003060; font-weight: bold">RubyJS</span><span style="color: #303030">::</span><span style="color: #003060; font-weight: bold">App</span>
  body <span style="color: #303030">=</span> <span style="background-color: #fff0f0">&quot;&lt;body&gt;&lt;div id=b1 class=button&gt;click me&lt;/div&gt;&lt;/body&gt;&quot;</span>
  <span style="color: #003060; font-weight: bold">HTML</span> <span style="color: #303030">=</span> <span style="color: #003060; font-weight: bold">RubyJS</span><span style="color: #303030">::</span><span style="color: #003060; font-weight: bold">App</span><span style="color: #303030">::</span><span style="color: #003060; font-weight: bold">HTML</span><span style="color: #303030">.</span>gsub(<span style="color: #000000; background-color: #fff0ff">/\&lt;body\&gt;.*\&lt;\/body\&gt;/</span>,body)
  
  <span style="color: #008000; font-weight: bold">def</span> <span style="color: #0060B0; font-weight: bold">on_ready</span> <span style="color: #303030">*</span>o
    alert(<span style="background-color: #fff0f0">&quot;Ruby&quot;</span>)
  
    xui(<span style="background-color: #fff0f0">&quot;#b1&quot;</span>)<span style="color: #303030">.</span>on <span style="background-color: #fff0f0">&quot;click&quot;</span> <span style="color: #008000; font-weight: bold">do</span>
	  alert <span style="background-color: #fff0f0">&quot;Hello World&quot;</span>
	<span style="color: #008000; font-weight: bold">end</span>
  <span style="color: #008000; font-weight: bold">end</span>
<span style="color: #008000; font-weight: bold">end</span>

app <span style="color: #303030">=</span> <span style="color: #003060; font-weight: bold">App</span><span style="color: #303030">.</span>run
</pre></td></tr></table></div></body>
EOS
  HTML = RubyJS::App::HTML.gsub(/\<body\>.*\<\/body\>/,body)
  
  def on_ready *o
    alert("Ruby")
  
    xui("#b1").on "click" do
	  alert "Hello World"
	end
  end
end

app = App.run
