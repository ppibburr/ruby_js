if __FILE__ == $0
  $: << Dir.getwd
  require 'rwt2'
end

module Rwt
  module UI
    module DragHandler
      @@instances = {}
      
      def attach grip,dragged=nil
        dragged = grip if !dragged
        grip.style.cursor = 'move'
        if !grip.is_a?(JS::Object)
          if grip.respond_to?(:element)
            grip = grip.element
          else
            raise
          end
        end
 
        if !dragged.is_a?(JS::Object) 
          if dragged.respond_to?(:element)
            dragged = dragged.element
          else
            raise
          end
        end 
                
        native.attach grip,dragged
      end
      
      def self.attach grip,dragged=nil
        if !@@instances.has_key?(grip.context)
          cls = Class.new
          cls.class_eval do
            include DragHandler
            attr_reader :document,:context,:native
            def initialize document
              @document = document
              @context = document.context
              @native = JS.execute_script(context,File.read("rwt-ui-draggable.js"))
              @@instances[context]=self
            end
            
            def method_missing *o,&b
              @native.send(*o,&b)
            end  
            
            def grip= q
              if @native.grip.is_a?(JS::Object)
                @native.grip.onmousedown=:undefined
                @native.grip.style.cursor='auto'
              end
              @native.grip = q
              q.onmousedown = @native['dragBegin']
              {
                :dragBegin=>proc do true end,
                :dragEnd=>proc do true end,
                :drag => proc do true end
              }.each_pair do |k,v|
                q[k.to_s]=v unless q[k.to_s].is_a?(JS::Object)
              end
              q.style.cursor = 'move'              
            end          
          end
          
          cls.new grip.ownerDocument
        end
        
        @@instances[grip.context].attach grip,dragged
      end
      
      def self.of q
        @@instances[q.context]
      end
    end
  end
end

if __FILE__ == $0
 def example1 document
  root = Rwt::UI::Collection.new(document)
  document.body.innerHTML="<div id=container style='overflow:hidden;width:250px;height:300px;background-color:#ebebeb;'><div id=handle>Drag here</div><div id=content>foo bar</div></div>"
  (h=root.find(:handle)[0]).style.cssText=("height:20px;width:100%;background-color:#cfcfcf")
  c=root.find(:container)[0]
  root.find('div').set_style('position','relative')
  root.find('div',c).set_style('border','1px solid #000').set_style('box-sizing','border-box')
  root.find(:content).set_style("height","280px").set_style('border-top','')
  Rwt::UI::DragHandler.attach(h,c)
 end  
 
 w = Gtk::Window.new 0
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
