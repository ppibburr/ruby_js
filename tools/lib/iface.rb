
#       iface.rb
             
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
class IFace
  attr_accessor :c_type_name,:includes,:ctor_method,:ruby_name,:is_module,:c_function_prefix,:functions,:source_header,:typedefs,:ctors,:ctor_functions,:ignore_functions
  def initialize
    @functions = []
    @includes = []
    @ctor_functions = []
    @ignore_functions = []
    @ctors = []
    @typedefs = {}
  end
  
  def build_function code;
		code =~ / (JS.*\(.*\))\;/
		function = $1
		if !function
			puts("not proccessing line of function \n\t#{code}\n")
			return
		end
		raw = code.gsub($1+";",'')
		ret = raw.strip
		
		function =~ /^(.*)\((.*)\)/
		
		name,params = $1,$2
		name = $1.split(" ").last

		is_ctor = false
		if ctor_functions.index(name)
		  is_ctor = true
      p name
		  func = Constructor.new(name)
    else
		  func = Function.new(name)
		end
    
		result = Function::Return.new(ret)
		func.result = result
		
		params.split(",").each do |prm|
			prm = prm.strip
			raw = prm.split(" ")
			pname = raw.last
			raw.delete_at(raw.length-1)
			ptype = raw.join(" ")
			func.add_parameter Function::Param.new(pname,ptype)
		end
		
		if is_ctor
		  ctors << func
		else
		  functions << func
		end
  end

	def define
		File.open(source_header,'r').readlines.each do |l|
			l = l.strip
				case l
			when /(^JS_EXPORT )/
				build_function l.gsub(/^JS_EXPORT /,'')
			end
		end
	end
  
  def get_type(t)
    if t == "char*"
      return :string
    end
    if get_cb(t.to_sym)
      return t
    elsif typedefs[t.to_s] || typedefs[t.to_sym]
      return t
    elsif FFI.find_type(t.to_sym)
      return t
    else
      :pointer
    end
  rescue
    :pointer
  end
end
