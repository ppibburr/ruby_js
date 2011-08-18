
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
  class GlobalContext < JS::Lib::GlobalContext
    include JS::Context

    class << self
      alias :real_new :new
    end  
      
    def self.new *o
      if o[0].is_a? Hash and o[0][:pointer] and o.length == 1
        real_new o[0][:pointer]
      else
        return JS::GlobalContext.create(*o)
      end
    end
      

    # Creates a global JavaScript execution context.
    #
    # @param [JSClassRef] globalObjectClass The class to use when creating the global object. Pass
    # @return [JS::GlobalContext] A JS::GlobalContext with a global object of class globalObjectClass.
    def self.create(globalObjectClass)
      res = super(globalObjectClass)
      wrap = self.new(:pointer=>res)
      return wrap
    end

    # Creates a global JavaScript execution context in the context group provided.
    #
    # @param [JS::ContextGroup] group The context group to use. The created global context retains the group.
    # @param [JSClassRef] globalObjectClass The class to use when creating the global object. Pass
    # @return [JS::GlobalContext] A JS::GlobalContext with a global object of class globalObjectClass and a context
    def self.create_in_group(group,globalObjectClass)
      res = super(group,globalObjectClass)
      wrap = self.new(:pointer=>res)
      return wrap
    end

    # Retains a global JavaScript execution context.
    #
    # @return [JS::GlobalContext] A JS::GlobalContext that is the same as ctx.
    def retain()
      res = super(self)
    end

    # Releases a global JavaScript execution context.
    #
    def release()
      res = super(self)
      return res
    end
  end
end
