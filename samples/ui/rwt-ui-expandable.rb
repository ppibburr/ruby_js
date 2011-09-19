if __FILE__ == $0
  require 'rwt2'
end
module Rwt
  module UI
    class Expander
      attr_reader :toggler,:expandee
      def initialize t,e
        @expandee = e
        @toggler = t
        
        Rwt::UI::Collection.new(nil,[@toggler]).on('click') do
          toggle()
        end
      end
      
      def toggle
        if @_shaded
          @expandee.style['height'] = @_shaded
          @_shaded = false
        else
          @_shaded = Rwt::UI::Collection.new(nil,[@expandee]).get_style('height')[0].to_f
          @expandee.style['height'] = (@toggler.clientHeight+2).to_s+"px"          
        end
      end
      
      def shaded?
        !!@_shaded
      end
    end
  end
end
if __FILE__ == $0
 def example1 document
  root = Rwt::UI::Collection.new(document)
  document.body.innerHTML="<div id=container style='overflow:hidden;width:250px;height:300px;background-color:#ebebeb;'><div id=handle>Click to shade/expand</div><div id=content>foo bar</div></div>"
  (h=root.find(:handle)[0]).style.cssText=("height:20px;width:100%;background-color:#cfcfcf")
  c=root.find(:container)[0]
  root.find('div',c).set_style('border','1px solid #000').set_style('box-sizing','border-box')
  root.find(:content).set_style("height","280px").set_style('border-top','')
  Rwt::UI::Expander.new(h,c)
 end  
 
 w = Gtk::Window.new
 v = WebKit::WebView.new
 w.add v
 v.load_html_string "<html><body style='width:800px;'></body></html>",nil
 
 v.signal_connect('load-finished') do |o,f|
   example1 f.get_global_context.get_global_object.document
 end
 
 w.signal_connect("delete-event") do
   Gtk.main_quit
 end
 
 w.show_all
 
 Gtk.main
end
