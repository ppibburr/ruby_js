require 'JS/html5/app'
require './pry'
def winHeight(window,document)
      return window.innerHeight || (document.documentElement || document.body).clientHeight;
end
class App < RubyJS::App
end
p RubyJS::Config.path
App.run() do
  shell.resize 400,400
  
  html = view.html
  head = html.head
  
  head.script :src=>'resource/code_mirror/lib/CodeMirror-2.3/lib/codemirror.js', :type=>"text/javascript"
  head.link   :rel=>"stylesheet", :href=>'resource/code_mirror/lib/CodeMirror-2.3/lib/codemirror.css'
  head.script :src=>'resource/code_mirror/lib/CodeMirror-2.3/mode/javascript/javascript.js'
  head.link   :rel=>"stylesheet", :href=>"resource/code_mirror/lib/CodeMirror-2.3/mode/javascript/javascript.css"
  head.script :src=>'resource/code_mirror/lib/CodeMirror-2.3/mode/ruby/ruby.js'
  head.script(:type=>'text/javascript',:src=>'resource/helpers.js')
  
  head.style(:type=>"text/css") do
   text """
      .CodeMirror-fullscreen {
        display: block;
        position: absolute;
        top: 0; left: 0;
        width: 100%;
        z-index: 9999;
      }
    """
  end

  on_ready do
    b1![0].value = File.read(__FILE__)
    
    cm = global_object['CodeMirror'].fromTextArea(b1![0], {
      :lineNumbers=> true,
      :mode => "ruby",
      :extraKeys => {
        "F11"=> proc {
          alert("f11")
        },
        "Esc"=> proc {
        }
      }
    });

    connect(window, "resize", proc {
      showing = document.body.getElementsByClassName("CodeMirror-fullscreen")[0];
      if (!showing)
      else
        showing.CodeMirror.getScrollerElement().style.height = winHeight(window,document).to_s + "px";
      end
      1
    })

    wrap = cm.getWrapperElement()
    scroll = cm.getScrollerElement()

    wrap.className += " CodeMirror-fullscreen";
    scroll.style.height = winHeight(window,document).to_s + "px";
    document.documentElement.style.overflow = "hidden";
 
    cm.refresh
    PryJack.new.pry(self)
  end
end
