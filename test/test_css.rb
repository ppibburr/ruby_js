require 'rubygems'
require 'gir_ffi'

require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')

GirFFI.setup "Gtk"

Gtk.init


w = Gtk::Window.new(:toplevel)
v = WebKit::WebView.new

v.load_html_string("""<!doctype html>
<html>
<head>
<style id=myRB type='text/css'>
#foo {
  color: #cecece;
}

.bar {
  color: #fff000;
}
</style>
</head>
<body>
<ul id=foo>
<li class=bar>text</li>
<li class=bar>more</li>
</ul>
</body>
</html>""",nil)
w.add v
w.show_all


class Collection
  def initialize q
    @q = q
  end
  
  def [] q
    self.new(find(q))
  end
  
  def find q
    if q.is_a?(String)
      if str =~ /^\.(.*)/
        find_of_class $1
      elsif str =~ /^\#(.*)/
        find_of_id $1
      else
        find_of_tag q
      end
    elsif q.is_a?(Symbol)
      find_of_id q.to_s
    end
  end
  
  def find_of_class q
    @q.getElementsByClass q
  end
  
  def find_of_id q
    @q.getElementById q
  end
  
  def find_of_tag q
    @q.getElementsByTagName(q)
  end
end

def ruby_do_dom ctx
  globj = ctx.get_global_object

  doc = globj['document']
  x=Collection.new(doc)
  p x[:foo].find(".bar")
  ;exit
  
rescue 
  puts "something went wrong"
  exit(1)
end

GObject.signal_connect(w,'delete-event') do 
  ruby_do_dom v.get_main_frame.get_global_context
  Gtk.main_quit
end

GObject.signal_connect(v,'load-finished') do |v,f|
  ruby_do_dom(f.get_global_context)
end

Gtk.main



