
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

      #         Creates a JavaScript string from a buffer of Unicode characters.
      #
      # @param [:size_t] numChars   The number of characters to copy from the buffer pointed to by chars.
      # @param [:pointer] chars      The buffer of Unicode characters to copy into the new JSString.
      # @return           A JSString containing chars. Ownership follows the Create Rule.
      def self.create_with_characters(chars,numChars)
        JS::Lib.JSStringCreateWithCharacters(chars,numChars)
      end

      #         Creates a JavaScript string from a null-terminated UTF8 string.
      #
      # @param [:pointer] string     The null-terminated UTF8 string to copy into the new JSString.
      # @return           A JSString containing string. Ownership follows the Create Rule.
      def self.create_with_utf8cstring(string)
        JS::Lib.JSStringCreateWithUTF8CString(string)
      end

      #         Retains a JavaScript string.
      #
      # @param [:JSStringRef] string     The JSString to retain.
      # @return           A JSString that is the same as string.
      def retain(string)
        JS::Lib.JSStringRetain(string)
      end

      #         Releases a JavaScript string.
      #
      # @param [:JSStringRef] string     The JSString to release.
      def release(string)
        JS::Lib.JSStringRelease(string)
      end

      #         Returns the number of Unicode characters in a JavaScript string.
      #
      # @param [:JSStringRef] string     The JSString whose length (in Unicode characters) you want to know.
      # @return           The number of Unicode characters stored in string.
      def get_length(string)
        JS::Lib.JSStringGetLength(string)
      end


      def get_characters_ptr(string)
        JS::Lib.JSStringGetCharactersPtr(string)
      end

      # Returns the maximum number of bytes a JavaScript string will
      #
      # @param [:JSStringRef] string The JSString whose maximum converted size (in bytes) you
      # @return The maximum number of bytes that could be required to convert string into a
      def get_maximum_utf8cstring_size(string)
        JS::Lib.JSStringGetMaximumUTF8CStringSize(string)
      end

      # Converts a JavaScript string into a null-terminated UTF8 string,
      #
      # @param [:pointer] buffer The destination byte buffer into which to copy a null-terminated
      # @param [:size_t] bufferSize The size of the external buffer in bytes.
      # @param [:JSStringRef] string The source JSString.
      # @return The number of bytes written into buffer (including the null-terminator byte).
      def get_utf8cstring(string,buffer,bufferSize)
        JS::Lib.JSStringGetUTF8CString(string,buffer,bufferSize)
      end

      #     Tests whether two JavaScript strings match.
      #
      # @param [:JSStringRef] a      The first JSString to test.
      # @param [:JSStringRef] b      The second JSString to test.
      # @return       true if the two strings match, otherwise false.
      def is_equal(a,b)
        JS::Lib.JSStringIsEqual(a,b)
      end

      #     Tests whether a JavaScript string matches a null-terminated UTF8 string.
      #
      # @param [:JSStringRef] a      The JSString to test.
      # @param [:pointer] b      The null-terminated UTF8 string to test.
      # @return       true if the two strings match, otherwise false.
      def is_equal_to_utf8cstring(a,b)
        JS::Lib.JSStringIsEqualToUTF8CString(a,b)
      end
    end
  end
end
