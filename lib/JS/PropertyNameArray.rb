
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
  class PropertyNameArray < JS::Lib::PropertyNameArray

    # Retains a JavaScript property name array.
    #
    # @return [JS::PropertyNameArray] A JS::PropertyNameArray that is the same as array.
    def retain()
      res = super(self)
      return JS::PropertyNameArray.new(res)
    end

    # Releases a JavaScript property name array.
    #
    def release()
      res = super(self)
      return res
    end

    # Gets a count of the number of items in a JavaScript property name array.
    #
    # @return [Integer] An integer count of the number of names in array.
    def get_count()
      res = super(self)
      return res
    end

    # Gets a property name at a given index in a JavaScript property name array.
    #
    # @param [Integer] index The index of the property name to retrieve.
    # @return [JS::String] A JS::StringRef containing the property name.
    def get_name_at_index(index)
      res = super(self,index)
      return JS.read_string(res)
    end
  end
end
