
#       PropertyNameArray.rb
             
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
    class PropertyNameArray < JS::BaseObject

      # Retains a JavaScript property name array.
      #
      # @param [:JSPropertyNameArrayRef] array The JSPropertyNameArray to retain.
      # @return A JSPropertyNameArray that is the same as array.
      def retain(array)
        JS::Lib.JSPropertyNameArrayRetain(array)
      end

      # Releases a JavaScript property name array.
      #
      # @param [:JSPropertyNameArrayRef] array The JSPropetyNameArray to release.
      def release(array)
        JS::Lib.JSPropertyNameArrayRelease(array)
      end

      # Gets a count of the number of items in a JavaScript property name array.
      #
      # @param [:JSPropertyNameArrayRef] array The array from which to retrieve the count.
      # @return An integer count of the number of names in array.
      def get_count(array)
        JS::Lib.JSPropertyNameArrayGetCount(array)
      end

      # Gets a property name at a given index in a JavaScript property name array.
      #
      # @param [:JSPropertyNameArrayRef] array The array from which to retrieve the property name.
      # @param [:size_t] index The index of the property name to retrieve.
      # @return A JSStringRef containing the property name.
      def get_name_at_index(array,index)
        JS::Lib.JSPropertyNameArrayGetNameAtIndex(array,index)
      end
    end
  end
end
