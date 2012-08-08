
#       GlobalContext.rb
             
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
    class GlobalContext < JS::BaseObject

      # Creates a global JavaScript execution context.
      #
      # @param [:JSClassRef] globalObjectClass The class to use when creating the global object. Pass
      # @return A JSGlobalContext with a global object of class globalObjectClass.
      def self.create(globalObjectClass)
        JS::Lib.JSGlobalContextCreate(globalObjectClass)
      end

      # Creates a global JavaScript execution context in the context group provided.
      #
      # @param [:JSClassRef] globalObjectClass The class to use when creating the global object. Pass
      # @param [:JSContextGroupRef] group The context group to use. The created global context retains the group.
      # @return A JSGlobalContext with a global object of class globalObjectClass and a context
      def self.create_in_group(group,globalObjectClass)
        JS::Lib.JSGlobalContextCreateInGroup(group,globalObjectClass)
      end

      # Retains a global JavaScript execution context.
      #
      # @param [:JSGlobalContextRef] ctx The JSGlobalContext to retain.
      # @return A JSGlobalContext that is the same as ctx.
      def retain(ctx)
        JS::Lib.JSGlobalContextRetain(ctx)
      end

      # Releases a global JavaScript execution context.
      #
      # @param [:JSGlobalContextRef] ctx The JSGlobalContext to release.
      def release(ctx)
        JS::Lib.JSGlobalContextRelease(ctx)
      end
    end
  end
end
