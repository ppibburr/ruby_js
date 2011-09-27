if __FILE__ == $0
  require 'rwt2'
end

module JS
  class Object
    alias :__val_at_key :'[]'

    
    def [] k
      v = __val_at_key k
      case v.class
      when Symbol
        if v == :undefined
          nil
        else
          v # never get here
        end
      else
        v
      end
    end
    
    def == q
      if q.respond_to?(:address)
        q == to_ptr.address
      elsif q.respond_to?(:to_ptr)
        q.to_ptr == to_ptr
      elsif q.respond_to?(:pointer)
        q.pointer == to_ptr
      else
        false
      end
    end
  end
end

module Rwt
 # module UI
    class Object
      def window
        context.get_global_object.window   
      end
      
      def document
        ownerDocument
      end
    end
 # end
end

module Rwt
  module Selection
    def save_selection()
      if (window.getSelection) 
          sel = window.getSelection();
          if (sel['getRangeAt'] && sel['rangeCount']) 
              return sel.getRangeAt(0);
          end
      elsif (document['selection'] && document.selection['createRange'])
          return document.selection.createRange();
      end
      return nil;
    end

    def restore_selection(range=@_ssel)
    p range
      if (range);p [:r, range]
        if (window['getSelection'])
            sel = window.getSelection();
            sel.removeAllRanges();
            p [:sel,sel]
            sel.addRange(range);
        elsif (document.selection && range.select)
            range.select();
        end
      end
    end
    
    def select_range range
      
    end
    
    def on_blur *o
      @_ssel = save_selection
    end
    
    def on_focus *o
      restore_selection(@_ssel) if @_ssel
    end
    
    def self.extended q
      q.on('blur',q.method(:on_blur))
      
      q.on('focus',q.method(:on_focus))
    end
  end
end

if __FILE__ == $0
  require "demo_common"
  Examples = ["foo"]
  STYLE = Rwt::STYLE
  Thread.abort_on_exception = true
  def example1 document
    root, window =base(document,1)
    tv=Rwt::TextView.new(root.find(:test)[0],"555"*30,:size=>[300,300])
    tv.show
      tv.extend Rwt::Selection
    Thread.new do
     sleep 3
    # p tv.on_blur.endOffset
   #  p tv.focus
     p r=tv.document.createRange();
     r.collapse true
     r.selectNode tv.element
     r.setStart(tv.element,5)
     r.setEnd tv.element,30
     sel=tv.window.getSelection()
     sel.removeAllRanges()
     sel.addRange(r)
     r.select
    end
  end
  

  
  launch
end
