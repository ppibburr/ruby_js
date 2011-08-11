module JS
  class String < JS::Lib::String

    class << self
      alias :real_new :new
    end  
      
    def self.new *o
      if o[0].is_a? Hash and o[0][:pointer] and o.length == 1
        real_new o[0][:pointer]
      else
        return JS::String.create_with_utf8cstring(*o)
      end
    end
      

    def self.create_with_characters(chars,numChars)
      res = super(chars,numChars)
      wrap = self.new(:pointer=>res)
      return wrap
    end

    def self.create_with_utf8cstring(string)
      res = super(string)
      wrap = self.new(:pointer=>res)
      return wrap
    end

    def retain()
      res = super(self)
      return JS.read_string(res)
    end

    def release()
      res = super(self)
      return res
    end

    def get_length()
      res = super(self)
      return res
    end

    def get_characters_ptr()
      res = super(self)
      return res
    end

    def get_maximum_utf8cstring_size()
      res = super(self)
      return res
    end

    def get_utf8cstring(buffer,bufferSize)
      res = super(self,buffer,bufferSize)
      return res
    end

    def is_equal(b)
      b = JS::String.create_with_utf8cstring(b)
      res = super(self,b)
      return res
    end

    def is_equal_to_utf8cstring(b)
      res = super(self,b)
      return res
    end
  end
end
