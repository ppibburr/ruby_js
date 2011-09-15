if __FILE__ == $0
  require 'rubygems'
  require 'ijs'
end

module UI
  module AsArray
    def each
      for i in 0..length-1
        yield self[i] if block_given?
      end 
    end
  end

  class Collection < Array
    def initialize from=nil,array=nil
      super array || []
      @from  = from
    end
    
    alias :'find!' :find
   
    def find( q=nil, context=@from,&b)
      if !q and !b
        return self if context == @from
        return self.class.new(context)
      end
    
      if !context and length > 0
        a=map do |o|
          Collection.new(o).find(q)
        end.flatten
        return self.class.new(nil,a)
      end
    
      raise "" unless (context.is_a?(JS::Object) || context.is_a?(UI::Object))

      q = "##{q}" if q.is_a?(Symbol)
      
      if q.is_a?(String)
        r=context.querySelectorAll(q)
        r.extend AsArray
        r=self.class.new(nil,r.map do |e| e.extend UI::Object;e; end)
        return r unless b
        return r.find(&b)  
      end
      if b?
        find!(&b)
      end
    end
    
    def on event,&b
      each() do |el|
          if (@events[type]) {
              var id = _getEventID(el), 
                  responders = _getRespondersForEvent(id, type);
              
              details = details || {};
              details.handler = function (event, data) {
                  xui.fn.fire.call(xui(this), type, data);
              };
              
              // trigger the initialiser - only happens the first time around
              if (!responders.length) {
                  xui.events[type].call(el, details);
              }
          } 
          el.addEventListener(type, _createResponder(el, type, fn), false);
      }); 
      self
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
      UI::Collection.new(nil,[self]).on(event,&proc)
    end
  end
end

if __FILE__ == $0
  include UI
  document.body.innerHTML="<div id=root><div id=child class=foo><div id=grandchild><div id=greatlevel></div></div></div></div>"
  p Collection.new(document).find(:child)[0]['id']
  p Collection.new(document).find(".foo").find('div')[1]['id']
end
