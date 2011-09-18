module Rwt
  module Draggable
    def self.extended q
      q.instance_variable_set("@dnd_handler", Rwt::UI::DragHandler.new(q))
    end
    attr_reader :dnd_handler
    def initialize *o
      super
      @dnd_handler=Rwt::UI::DragHandler.new(self)
    end
      
    
    def make_draggable
      return if @_dnd_handler
    end
    
    def set_dragged q
      dnd_handler.dragged = q
    end
    
    def no_drag!
      @dnd_handler = nil
      self.onmousedown = :undefined
    end
  end
end
