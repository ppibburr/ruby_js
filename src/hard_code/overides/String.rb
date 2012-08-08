
#       String.rb
             
#		(The MIT License)
#
#        Copyright 2011 Matt Mesanko <tulnor@linuxwaves.com>
#
#		Permission is hereby granted, free of charge, to any person obtaining
#		a copy of this software and associated documentation files (the
#		'Software'), to deal in the Software without restriction, including
#		without limitation the rights to use, copy, modify, merge, publish,
#		distribute, sublicense, and/or sell copies of the Software, and to
#		permit persons to whom the Software is furnished to do so, subject to
#		the following conditions:
#
#		The above copyright notice and this permission notice shall be
#		included in all copies or substantial portions of the Software.
#
#		THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
#		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
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
      

    #         Creates a JavaScript string from a buffer of Unicode characters.
    #
    # @param [FFI::Pointer] chars      The buffer of Unicode characters to copy into the new JS::String.
    # @param [Integer] numChars   The number of characters to copy from the buffer pointed to by chars.
    # @return [JS::String]           A JS::String containing chars. Ownership follows the Create Rule.
    def self.create_with_characters(chars,numChars)
      res = super(chars,numChars)
      wrap = self.new(:pointer=>res)
      return wrap
    end

    #         Creates a JavaScript string from a null-terminated UTF8 string.
    #
    # @param [FFI::Pointer] string     The null-terminated UTF8 string to copy into the new JS::String.
    # @return [JS::String]           A JS::String containing string. Ownership follows the Create Rule.
    def self.create_with_utf8cstring(string)
      res = super(string)
      wrap = self.new(:pointer=>res)
      return wrap
    end

    #         Retains a JavaScript string.
    #
    # @return [JS::String]           A JS::String that is the same as string.
    def retain()
      res = super(self)
      return JS.read_string(res)
    end

    #         Releases a JavaScript string.
    #
    def release()
      res = super(self)
      return res
    end

    #         Returns the number of Unicode characters in a JavaScript string.
    #
    # @return [Integer]           The number of Unicode characters stored in string.
    def get_length()
      res = super(self)
      return res
    end


    def get_characters_ptr()
      res = super(self)
      return res
    end

    # Returns the maximum number of bytes a JavaScript string will
    #
    # @return [Integer] The maximum number of bytes that could be required to convert string into a
    def get_maximum_utf8cstring_size()
      res = super(self)
      return res
    end

    # Converts a JavaScript string into a null-terminated UTF8 string,
    #
    # @param [FFI::Pointer] buffer The destination byte buffer into which to copy a null-terminated
    # @param [Integer] bufferSize The size of the external buffer in bytes.
    # @return [Integer] The number of bytes written into buffer (including the null-terminator byte).
    def get_utf8cstring(buffer,bufferSize)
      res = super(self,buffer,bufferSize)
      return res
    end
    
    def to_s
      size = get_length
      get_utf8cstring a=FFI::MemoryPointer.new(:pointer,size+1),size+1
      a.read_string
    end

    #     Tests whether two JavaScript strings match.
    #
    # @param [JS::String] b      The second JS::String to test.
    # @return [boolean]       true if the two strings match, otherwise false.
    def is_equal(b)
      b = JS::String.create_with_utf8cstring(b)
      res = super(self,b)
      return res
    end

    #     Tests whether a JavaScript string matches a null-terminated UTF8 string.
    #
    # @param [FFI::Pointer] b      The null-terminated UTF8 string to test.
    # @return [boolean]       true if the two strings match, otherwise false.
    def is_equal_to_utf8cstring(b)
      res = super(self,b)
      return res
    end
  end
end
