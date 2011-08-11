
module JS
  class BaseObject
    attr_accessor :pointer
    def initialize ptr
      @pointer = ptr
    end
    
    def to_ptr
      @pointer
    end
    
    def is_self ptr
      return nil if !ptr
      if ptr.respond_to?(:address) and self.pointer.address == ptr.address
        return self
      end
      
      return nil
    end    
  end
end

def check_use ptr
  nil
end
    
    
