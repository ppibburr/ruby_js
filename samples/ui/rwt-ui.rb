if __FILE__ == $0
  require 'rubygems'
  require 'ijs'
end

begin
  require "JS"
rescue LoadError
  require 'rubygems'
  require 'JS'
end

require "JS/webkit"
require "JS/props2methods"

module Rwt
  module UI
    require 'rwt-ui-draggable'
    require 'rwt-ui-expandable'
    require 'rwt-ui-scrollable'
    
    module AsArray
      def each
        for i in 0..length-1
          yield self[i] if block_given?
        end 
      end
    end

    class Collection < Array
      def initialize from=nil,array=nil
        array = array.map do |el|
          el.extend UI::Object if !el.is_a?(UI::Object)
          if el.respond_to?(:element)
            el.element 
          else
           el 
          end
        end if array
        array ||= []
        
        super array
        
        @from  = from
      end
      
      alias :'find!' :find
     
      def find_long( all=false,q=nil, context=@from,&b)
        if !q and !b
          return self if context == @from
          return self.class.new(context)
        end
      
        if !context and length > 0
          a=map do |o|
            Collection.new(o).find_long(all,q)
          end.flatten
          return self.class.new(nil,a)
        end
      
        raise "" unless (context.is_a?(JS::Object) || context.is_a?(UI::Object))

        q = "##{q}" if q.is_a?(Symbol)
        
        if q.is_a?(String)
          if all
            r=context.querySelectorAll(q) 
            r.extend AsArray
            r=self.class.new(nil,r.map do |e| e.extend UI::Object;e; end)
          else
            r=context.querySelector(q) if !all
            r.extend UI::Object
          end
          return r unless b
          return r.find(&b)  
        end
        if b?
          find!(&b)
        end
      end
      
      def find *o
        find_long true,*o
      end
      
      def on type,&fn
        each() do |el|
          el.addEventListener(type, createResponder(el, type, fn), false);
        end
        self
      end
      
      # lifted from Prototype's (big P) event model
      def getEventID(element)
        if (element['uiEventID']) then return element['uiEventID'] end;
        return element['uiEventID'] = @@nextEventID+=1;
      end

      @@nextEventID = 1;
      @@cache = {}
      def getRespondersForEvent(id, eventName)
          c = @@cache[id] ||= {};
          return c[eventName] ||= [];
      end

      def createResponder(element, eventName, handler)
          id = getEventID(element)
          r = getRespondersForEvent(id, eventName);
          if @from
            ctx = @from.context
          else
            ctx = self[0].context
          end
          responder = JS::Object.new(ctx, proc {|this,event|;
              if (!handler.call(element, event))
                  event.preventDefault();
                  event.stopPropagation();
              end
          });
          handler = JS::Object.new(ctx,handler)
          responder.guid = handler['guid'] ||= @@nextEventID+=1;
          responder.handler = handler;
          r.push(responder);
          return responder;
      end
      
      def fire(type, data=nil)
        each do |el|
          if (el == el.ownerDocument && (!el['dispatchEvent'] || el['dispatchEvent']==:undefined))
              el = document.documentElement;
          end
          
          event = el.ownerDocument.createEvent('HTMLEvents');
          event.initEvent(type, true, true);
          event.data = data || {};
          event.eventName = type;

          el.dispatchEvent(event);
        end;
        self
      end  
      
      def add_class n
        each do |el|
          el.className = (el.className + " #{n}").strip
        end
        self
      end
      
      def remove_class n
        each do |el|
          el.className = el.className.strip.split(" ").find_all do |b| b != n end.join(" ")
        end
        self    
      end
      
      def toggle_class n
        if el.className.split(" ").index(n.strip)
          remove_class n
        else
          add_class n
        end
      end
      
      def has_class n
        self.class.new(nil,find_all do |el|
          el.className.split(" ").index(n.strip)
        end)
      end  
      
      def has q
        self.class.new(nil,self).find q
      end
      
      def not q
        res = find_all do |el| !has(q).index(el) end
        self.class.new(nil,res)
      end
      
      def get_style(prop)
        map do |el|
          el.ownerDocument.defaultView.getComputedStyle(el, "").getPropertyValue(prop) 
        end
      end
      
      def set_style prop,value
        each do |el|
          el.style[prop] = value
        end
        self
      end
      
      def attr attribute,val=nil
        if (val)
          each do |el|
            if (el.tagName == 'input' && attribute == 'value')
              el.value = val;
            elsif (el['setAttribute'] and el['setAttribute'].is_a?(JS::Object))
              if (attribute == 'checked' && (val == '' || val == false || val == :undefined))
                el.removeAttribute(attribute);
              else
                el.setAttribute(attribute, val);
              end
            end
          end
          return self;
        else
          map do |el|
            if (el.tagName == 'input' && attribute == 'value') 
              el.value;
            elsif (el['getAttribute'] && el['getAttribute'].is_a?(JS::Object))
              el.getAttribute(attribute) || '';
            end
          end;
        end
      end
    end  
      
    module Object
      def descendents
        getElementsByTagName('*');    
      end
      
      def typeof
        JS.execute_script(context,"typeof(this)",self)
      end
      
      def find q
        UI::Collection.new(self).find(q)
      end
      
      def on event,to_proc=nil,&b
        proc = b
        proc = to_proc.to_proc if to_proc
        to_collection.on(event,&proc)
      end
      
      def fire event,data=nil
        to_collection.fire event,data
      end
      
      def to_collection
        UI::Collection.new(nil,[self])
      end
      
      def extend_object o
        o.each_pair do |k,v|
          self[k.to_s] = v
          p self[k.to_s]
        end
      end
    end
  end
end
if __FILE__ == $0
  include Rwt::UI
  JS.execute_script(document.context,File.read("xui.js"))
  document.body.innerHTML="<div id=root><div id=child class=foo><div id=grandchild class=bar><div id=greatlevel class=bar></div></div><div class=bar id=notgrandchild></div></div></div>"
  p Collection.new(document).find(:child)[0]['id']
  Collection.new(document).find('.foo').find('div').on('click') do
    p 1
    false
  end
  aUi=Collection.new(document).find("#root").find("div")
  aUi.find('div').fire('click')
  aUi.find('div')[0].fire('click')
  p aUi.has(".bar")[1]['id']
  p aUi.not(".foo")[0]['id']
  p aUi.set_style("color","blue").get_style('display')
  p aUi.attr('name','6').attr('name')
  #GLOBAL.xui('.foo')['find'].call('div').fire('click')
end
