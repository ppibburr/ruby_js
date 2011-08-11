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
