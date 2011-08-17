
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
  module Lib
    class String < JS::BaseObject

      # @param chars => :pointer
      # @param numChars => :size_t
      # retuen => JSStringRef
      def self.create_with_characters(chars,numChars)
        JS::Lib.JSStringCreateWithCharacters(chars,numChars)
      end

      # @param string => :string
      # retuen => JSStringRef
      def self.create_with_utf8cstring(string)
        JS::Lib.JSStringCreateWithUTF8CString(string)
      end

      # @param string => :JSStringRef
      # retuen => JSStringRef
      def retain(string)
        JS::Lib.JSStringRetain(string)
      end

      # @param string => :JSStringRef
      # retuen => void
      def release(string)
        JS::Lib.JSStringRelease(string)
      end

      # @param string => :JSStringRef
      # retuen => size_t
      def get_length(string)
        JS::Lib.JSStringGetLength(string)
      end

      # @param string => :JSStringRef
      # retuen => pointer
      def get_characters_ptr(string)
        JS::Lib.JSStringGetCharactersPtr(string)
      end

      # @param string => :JSStringRef
      # retuen => size_t
      def get_maximum_utf8cstring_size(string)
        JS::Lib.JSStringGetMaximumUTF8CStringSize(string)
      end

      # @param string => :JSStringRef
      # @param buffer => :pointer
      # @param bufferSize => :size_t
      # retuen => size_t
      def get_utf8cstring(string,buffer,bufferSize)
        JS::Lib.JSStringGetUTF8CString(string,buffer,bufferSize)
      end

      # @param a => :JSStringRef
      # @param b => :JSStringRef
      # retuen => bool
      def is_equal(a,b)
        JS::Lib.JSStringIsEqual(a,b)
      end

      # @param a => :JSStringRef
      # @param b => :string
      # retuen => bool
      def is_equal_to_utf8cstring(a,b)
        JS::Lib.JSStringIsEqualToUTF8CString(a,b)
      end
    end
  end
end
