require 'JS/application'
class Template
  attr_reader :document,:style
  HTML = "<head><title></title><style type=text/css></style></head><body></body>"
  def initialize document
    document.getElementsByTagName('html')[0].innerHTML = self.class::HTML
    @document = document
  end
  
  def use_style sty
    @style = sty
  end
  
  def build &b
    JS::DOM::Builder.build(document.context.get_global_object,document.body,&b)  
  end
  
  def to_s
    @style.element.childNodes.length.times do
      @style.element.removeChild( @style.element.firstChild )
    end if @style.element.hasChildNodes
    for i in 1..@style.rules.length
        k = document.createTextNode('');
        @style.element.appendChild(k)
        k.nodeValue = @style.rules[i-1].cssText
    end
    document.documentElement.outerHTML
  end
  
  class Style
    class Builder
      def initialize sty
        @style = sty
      end
      def method_missing m,o
        @style[m]=o
      end
    end
    attr_reader :element,:document,:sheet
    def initialize document
      @document = document
      @sheet = document.styleSheets[document.styleSheets.length - 1]; 
      @element = document.getElementsByTagName('style')[0]
    end
    
    def rules
      a=[]
      for i in 1..sheet.rules.length
        a << sheet.rules.item(i-1)
      end
      a    
    end
    
    def has_rule?(r)
      rules.find do |st| st.selectorText == r end
    end
    
    def rule r,&b
      if !rl=has_rule?(r)
        sheet.insertRule(q="#{r} {}",0)
        rl=sheet.rules[0]
      end
      Builder.new(rl.style).instance_eval &b
      r
    end
  end  
end

class MyApp < JS::Application
  class MyTemplate < Template
    class MyStyle < Style
      def initialize *o
        super
        rule "#content" do 
          backgroundColor "red"
        end
        
        rule "#header" do
          color "green"
        end
      end
    end
    
    def initialize *o
      super
      
      use_style MyStyle.new(document)
      
      build do
        h1 'id'=>"header" do
          text "change the header"
        end
        div "class"=>"foo","id"=>"content" do
          text "change the content"
        end
      end
    end
  end
  
  def on_render
    pages = []
    for i in 0..5
       pg = MyTemplate.new(document)
       document.getElementsByTagName('title')[0].innerText = "Page #{i}"
       document.getElementById('header').innerText = "page header #{i}"
       document.getElementById('content').innerText = "this is page #{i}"
       pages << pg.to_s
    end
    puts pages.join("\n")
  end
end

MyApp.new.run
