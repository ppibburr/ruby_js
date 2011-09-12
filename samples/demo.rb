require 'rubygems'
require 'ffi'

require 'JS'
require 'JS/props2methods'
require 'JS/webkit'

require 'JS/resource'
require '/home/ppibburr/git/ruby_js/src/hard_code/rwt'

require 'box'
require 'sizing'
require 'button'
require 'panel'
require 'layout'
require 'tab'

class DemoRunner
  EXAMPLES={}
  attr_reader :r,:w,:t
  def initialize doc
    @@instance = self
    @r = Rwt::Collection.new(doc,[doc])
    return if __FILE__ != $0
    @w=Rwt::Dow.new(r.find(:app)[0],'Demo',:size=>[600,400],:position=>[15,15])
    @w.add vb=Rwt::VBox.new(w)
    vb.add @t=Rwt::Tabbed.new(vb),1,1
    Dir.glob("#{File.dirname(__FILE__)}/demo_*.rb").each do |f|
      EXAMPLES[File.basename(f)] = f 
    end
  end
  
  def self.run_instance(doc)
    i=self.new doc
    return if __FILE__ != $0

    EXAMPLES.each_pair do |n,v|
      load(v)
      ex=i.t.pages.last.children[0]
      ex.style.position='relative'
      ex.set_position Rwt::Point.new(ex.position[0]+5,ex.position[1]+5)
    end
    i.w.show
    i.t.page(0).element.onresize(nil,0,0)
  end
  
  def self.run_standalone_demo meth
    run(meth)
  end
  
  def self.get_target f
    if __FILE__ == $0
      n=File.basename(f)
      @@instance.t.add(n)
    else
      @@instance.r.find(:app)[0]
    end
  end
  
  def self.on_webview_load_finished ctx,meth=nil
    globj = ctx.get_global_object
    doc = globj['document']
    rwt=Rwt::Collection.new(doc,[doc])  
    Rwt.init doc
    
    JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/tab.css")
    JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/box.css")
    JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/button.css") 
    JS::Style.load(doc,"/home/ppibburr/git/ruby_js/samples/proper.css")  
      
    run_instance(doc)
    meth.call if meth
  end
end

class DemoRunner
  def self.run meth=nil
    w = Gtk::Window.new()
    v = WebKit::WebView.new

    v.load_html_string("""<!doctype html>
    <html>
      <body>
        <div id=app></div>
      </body>
    </html>""",nil)

    w.add v
    w.resize(800,600)
    w.show_all

    w.signal_connect('delete-event') do 
      Gtk.main_quit
    end

    v.signal_connect('load-finished') do |yv,f|
      on_webview_load_finished(f.get_global_context,meth)
    end

    Gtk.main
  end
end

if __FILE__ == $0
  DemoRunner.run
end
