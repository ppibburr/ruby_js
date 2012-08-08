require 'rubygems'
require 'JS/html5'
<<<<<<< HEAD
require 'JS/html5/helpers/gir_ffi/subclass_normalize.rb'
=======
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
module RubyJS
  class Config
    # path to included resources
    def self.path
      "file:///home/ppibburr/sync/ruby_js/src/hard_code/html5/"
    end
  end
  
  # includes standard resource
  # xui.js, small with powerful dom utilites
  # helpers.js, mainly allows
  def self.default_html
    html = HtmlBuilder::HtmlTag.new
    html.build do
      head do
        link(:rel=>"stylesheet",:type=>"text/css",:href=>"#{RubyJS::Config.path}/resource/styles.css")
        script(:type=>"text/javascript",:src=>"#{RubyJS::Config.path}/resource/xui.js")
        script(:type=>"text/javascript",:src=>"#{RubyJS::Config.path}/resource/helpers.js")
      end
      body do
        div(:id=>"b1",:class=>"button") do
          text "click me"
        end
      end
    end
    html
  end
  
<<<<<<< HEAD
  module Xui
    module Helper
      def tween *props,&cb
        p0 = props[0] || {}
        props = p0.to_hash
        window = context.get_global_object
        emile = [:duration,:after,:easing]
        props.each_pair do |k,v|
          next if emile.index(k)
          if ["top","left","z-index"].index(k.to_s)
            getStyle('position').each_with_index do |q,i|
              self[i].style.position = "absolute"
            end

            getStyle("#{k}").each_with_index() do |q,i|
              if q !~ /[0-9]/
                top = Xui::Helper.absPos(self[i],:top)
                left = Xui::Helper.absPos(self[i],:left)
                self[i].style.top = "#{top}px"
                self[i].style.left = "#{left}px"              
              end
            end
          end
          q = getStyle("#{k}").map do |s| s end
          q.each_with_index do |s,i|
            if s == "rgba(0, 0, 0, 0)"
              self[i].style[k.to_s] = "#fff"
            end
          end
          p q
        end
                  
        self['tween'].call(props,&cb)
      end
      
      def self.absPos( o, tl )
        val = 0;
        while ( o.nodeName != "BODY" )
          val +=  (tl == :top ? o.offsetTop : o.offsetLeft).to_f;
          o = o.parentNode;
        end
      return val;
      end
    end
  end
  
=======
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
  class HtmlBuilder
    class Tag
      attr_reader :builder,:tag,:atts
      attr_accessor :parent
      def initialize tag,*o,&b
        super()
        @tag = tag
        raise unless !o[0] or o[0].respond_to?(:to_hash)
        @atts = o[0] || {}
        @builder = HtmlBuilder.new(self)
        
        build(&b) if b 
      end
      def build &b
        instance_eval(&b)
      end
      def define q,v
        @_self ||= class << self
          self
        end 
        if v.is_a?(Method)
          @_self.class_eval do 
            define_method q do |*o,&b|
              v.call *o,&b
            end
          end
        else
          @_self.class_eval do
            define_method q do
              v
            end
          end
        end
        p self.method(q)
      end
      def method_missing m,*o,&b
        if parent and parent.respond_to?(m)
          return parent.send(m.to_s,*o,&b)
        end
        builder.send(m.to_s,*o,&b)
      end
    
      def outer
        a = []
        atts.each_pair do |k,v|
          a << "#{k}=\"#{v}\""
        end
        ["<#{tag} #{a.join(" ")}>",inner,"</#{tag}>"].join()      
      end
      def inner
        builder.to_s
      end
      def inner= builder
        raise unless builder.is_a?(HtmlBuilder)
        @builder = builder
      end
      def to_s
        outer
      end
      def replace &b
        self.inner = HtmlBuilder.new(self)
        build(&b)
      end
      def on evt,m,*o
        args = o.join(",")
        atts[:"on#{evt}"] = "ruby_object.#{m}(#{args});"
      end
    end
    
    class HtmlTag < Tag
      def initialize
        super :html
      end
      def head *o,&b
        if !@head
          method_missing(:head,*o,&b)
        end
        @head = find_tags(:head)[0]
      end
      def body *o,&b
        if !@body
          method_missing(:body,*o,&b)
        end
        @body = find_tags(:body)[0]
      end
    end    
    
    def build &b
      instance_eval(&b)
    end
    attr_reader :tags,:parent
    def initialize parent=nil
      @parent = parent
      @tags = []
    end
    def text value
      @tags << value
    end
    def method_missing m,*o,&b
      if m.to_s =~ /\!$/
        return find_id(m.to_s.gsub(/\!$/,''))
      end
      tags << t=Tag.new(m.to_s,*o)
      t.parent = self.parent
      t.build &b if b
    end
    def find_tags(tag)
      tag = tag.to_s
      @tags.find_all do |t|
        t.tag == tag
      end
    end
    def find_id id
      r = @tags.find do |t|
        t.atts[:id] == id
      end
      return r if r
      tag = nil
      @tags.each do |t|
        tag = t.builder.find_id(id)
      end
      if tag
        return tag
      end
      return nil
    end
    def to_s
      @tags.map do |t|
        t.to_s
      end.join()
    end
  end
    
  class View < WebKit::WebView 
<<<<<<< HEAD
=======
    @@_instances = {}
    
    def self.instances
      @@_instances
    end
    
    class << self
      alias :_new :new
      alias :_wrap :wrap
    end
    
    def self.wrap ptr
      q = instances[ptr.address]
      return q if q
      raise "Wrapping of a subclassed View or View, that wasnt created by ruby?? "
    end
    
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
    attr_accessor :html
    attr_reader :ruby_object
    alias :_init :initialize   
    
    def initialize ruby_object=self,*o
<<<<<<< HEAD
      super()
=======
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
      @ruby_object = ruby_object
      @html = RubyJS.default_html
      
      signal_connect("load-started") do
        load_started
      end

      signal_connect("load-finished") do
        load_finished
      end
    end
    
    def load base="File://#{File.expand_path(File.dirname(__FILE__))}"
      load_html_string html.to_s,base
    end
    
    def dom_ready this
      p :dom_ready
      b1!.on "click" do
        Gtk.main_quit
      end
    end
    
    def method_missing m,*o,&b
      if global_object.has_property(m.to_s)
        if (prop=global_object[m]).is_function
          return prop.call(*o,&b)
        else
          return prop
        end
      elsif m.to_s =~ /\!$/
        return xui("##{m.to_s.gsub(/\!$/,'')}")
      end
      super
    rescue
      super
    end    
    
    def xui(*o,&b)
<<<<<<< HEAD
      global_object["x$"].call(*o,&b).extend Xui::Helper
=======
      global_object["x$"].call(*o,&b)
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
    end
    
    def load_started
      @global_object ||= get_main_frame.get_global_context.get_global_object
      global_object.handler = method(:dom_ready)
      global_object.ruby_object = @ruby_object
    end
    
    def global_object
      @global_object
    end
    
    def load_finished
    p :finish
    end
<<<<<<< HEAD
=======
    
    def self.new *o
      obj = alloc
      ptr = RubyJS::View.superclass.new().to_ptr
      @@_instances[ptr.address] = obj
      obj.send :_init,ptr
      obj.send :initialize,*o
      obj
    end
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
  end
end

class Object
  class << self
    alias :alloc :allocate
  end
end

module RubyJS
  class App
    class View < RubyJS::View
      attr_reader :application
      def initialize app,ruby_object = self
        @application = app
        super(ruby_object)
      end
      def dom_ready this
        @application.dom_ready(self)
      end
    end
    
    class Shell < Gtk::Window
<<<<<<< HEAD
      attr_accessor :root,:header,:content,:footer,:views
      def initialize application,*o
        super(:toplevel)
=======
      @@_instances = {}
      def self.instances
        @@_instances
      end
      class << self
        alias :_new :new
        alias :_wrap :wrap
      end
      alias :_init :initialize      
      def self.wrap ptr
        q = instances[ptr.address]
        return q if q
        raise "Wrapping of a subclassed Shell or Shell, that wasnt created by ruby?? "
      end  
    
      attr_accessor :root,:header,:content,:footer,:views
      def initialize application,*o
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
        @application = application
        @views = []
        
        add @root = Gtk::VBox.new(false,0)
        
        root.pack_start @header = Gtk::VBox.new(false,0),false,true,0
        header.pack_start Gtk::Button.new(),true,true,0
        root.pack_start @content = Gtk::VBox.new(false,0),true,true,0
        root.pack_start @footer = Gtk::VBox.new(false,0),false,true,0
        
        signal_connect "delete-event" do
          Gtk.main_quit
        end
      end
      
      attr_reader :views,:application
      
      def create_view(parent=content)
        view = view || application.class::View.new(application,application)
        sw = Gtk::ScrolledWindow.new(nil,nil)
        sw.add view
        parent.pack_start sw,true,true,1
        view
      end
      
      def add_view view=nil
        view ||= create_view()
        @views << view
        view
      end
<<<<<<< HEAD
=======
      
      def self.new *o
        obj = alloc
        ptr = RubyJS::App::Shell.superclass.new(:toplevel).to_ptr
        @@_instances[ptr.address] = obj
        obj.send :_init,ptr
        obj.send :initialize,*o
        obj
      end
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
    end
    
    attr_reader :shells
    def initialize
      @shell = Shell.new(self)
      @shells = []
      @shells << @shell
      @on_ready_cb = {}
    end
    
    def dom_ready view
      view.instance_eval &@on_ready_cb[view]
    end
    
    def on_ready view=shells[0].views[0],&b
      @on_ready_cb[view] = b
    end   
    
    def shell
      shells[0]
    end
    
    def view
      shell.views[0]
    end
    
    def run *opts,&b
      opts = (opts[0]||{}).to_hash
      view = shells[0].add_view
      instance_eval &b if b
      view.load q=opts[:base_uri]||RubyJS::Config.path
      shells[0].show_all  
    end
    
    def self.run *opts,&b
      Gtk.init []
      app = new
      app.run *opts,&b
      Gtk.main
    end
  end
end
<<<<<<< HEAD

=======
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
if __FILE__ == $0
  class MyApp < RubyJS::App; 
    def button_clicked this
      shells[0].views[0].alert this
    end
  end

<<<<<<< HEAD
  def loop_bounce collection
    collection.tween(:left=>'200px',:backgroundColor=>"#F80303",:top=>"200px",:duration=>750) do
      collection.tween(:backgroundColor=>"#cecece",:top=>"0px",:duration=>750) do
        collection.tween(:left=>'0px',:backgroundColor=>"#F80303",:top=>"200px",:duration=>750) do
          collection.tween(:backgroundColor=>"#FFF",:top=>"0px",:duration=>750) do
            loop_bounce(collection)
          end
        end
      end
    end
  end

=======
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
  MyApp.run do 
    shell.resize 400,400
    
    view.html.body.replace do
      div(:class=>'button',:id=>'b1') do
        on :click, :button_clicked,'this'
        text "Click me"
      end
    end

    on_ready() do
<<<<<<< HEAD
      loop_bounce b1!
=======
      alert("Ruby")
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
    end
  end
end
