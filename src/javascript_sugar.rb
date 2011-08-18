
#       javascript_sugar.rb
             
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
CALLBACK_CODE = """
      JS::CallBack.new(%(cb_pname))
"""
class JavaScript < Sugar
  attr_accessor :target
  def initialize lib
    super()
    @lib = lib
    @lib_name = "JS"
    @target = lib.target
    @params_may_be_nil = {
      :JSObjectCallAsFunction=>4,
      :JSObjectMake=>1,
      :JSObjectMakeConstructor=>1,
      :JSObjectMakeFunctionWithCallback=>1,
      :JSObjectCallAsConstructor=>3,
      :JSObjectSetProperty=>4,
      :all_functions_when_name_is_last=>["exception"]
    }
    
    add_method_note :JSObjectCallAsFunction, "@note A convienience method is at JS::Object#call\n    # @see Object#call"
    add_param_default :JSObjectCallAsFunction,3,0
    add_param_default :JSObjectCallAsConstructor,2,0
    add_param_default :JSObjectCallAsFunction,2,'nil'
  end
  
  def open_iface *o
    super
    @co.puts """
  attr_accessor :context
  
  def self.from_pointer_with_context(ctx,ptr)
    res = self.new(:pointer=>ptr)
    res.context = ctx
    res
  end
    """ if !@in_iface.is_module and ["Value","Object"].index(@in_iface.ruby_name)
  end
  
  def handle_params sm,f,amt=0
    pnames = sm.pnames[amt..sm.pnames.length-1]
    cb = nil
    if sm.ptypes.last and @lib.get_cb(sm.ptypes.last.to_sym)
      cb = pnames[pnames.length-1] = "&#{pnames.last}"
    end
    if idx=@params_may_be_nil[f.name.to_sym]
      idx = idx - amt
      for i in idx..pnames.length-1
        pnames[i] = pnames[i]+" = nil" unless cb == pnames[i]
      end
    end
    if ary=@param_defaults[f.name.to_s.to_sym]
      ary.each do |a|
        pnames[a[0]-amt]=pnames[a[0]-amt]+ " = "+a[1].to_s
      end
    end
    if a=@params_may_be_nil[:all_functions_when_name_is_last]
      if a.index(pnames.last);
        pnames[pnames.length-1] = pnames.last+" = nil"
      end
    end

    return pnames
  end
  
  def write_cast_param_code(sm,offset=0)
    pt = sm.ptypes[offset..sm.ptypes.length-1]
    pn = sm.pnames[offset..sm.pnames.length-1]
    pt.each_with_index do |t,i|
      case t.to_s.to_sym
      when :JSValueRef
        @co.puts "      #{pn[i]} = JS::Value.from_ruby(context,#{pn[i]})"  unless sm.array_params.find do |q| q[0] == pn[i] end
      when :JSObjectRef
        @co.puts "      #{pn[i]} = JS::Object.from_ruby(context,#{pn[i]})"  unless sm.array_params.find do |q| q[0] == pn[i] end
      when :JSStringRef
        @co.puts "      #{pn[i]} = JS::String.create_with_utf8cstring(#{pn[i]})"  unless sm.array_params.find do |q| q[0] == pn[i] end
      when :JSObjectCallAsFunctionCallback
        @co.puts "      #{pn[i]} = JS::CallBack.new(#{pn[i]})"
      end
    end
  end
  
  def build_function sm,f,cls = false, ctor = false
    prefix = ''
    if cls
      prefix = 'self.'
    end
    sm.ptypes = sm.ptypes.map do |pt| pt = pt.gsub(":",'') end
    ct=@in_iface.c_type_name
    fp=@in_iface.c_function_prefix
    if f.name =~ Regexp.new("^#{fp}") # check for iface_method
      @co.puts "\n"\

      if sm.ptypes[0].to_s == ct # object method prepend self
        if sm.pnames.length == 1
          @co.puts desc_params(4,[],sm)
          @co.puts "    def #{prefix}#{sm.symbol}()"
          if @in_iface.is_module
            @co.puts "      res = #{@lib.lib_name}::Lib.#{f.name}(self)"
          else
            @co.puts "      res = super(self)"
          end
        else
          pnames = handle_params sm,f,1
          @co.puts desc_params(4,pnames,sm,1)
          
          @co.puts "    def #{prefix}#{sm.symbol}(#{pnames.join(",")})"
          write_cast_param_code(sm,1)
          if @in_iface.is_module
            @co.puts "      res = #{@lib.lib_name}::Lib.#{f.name}(#{sm.pnames[1..sm.pnames.length-1].join(",")})"
          else
            @co.puts "      res = super(self,#{sm.pnames[1..sm.pnames.length-1].join(",")})" 
          end
        end
      elsif sm.ptypes[0].to_s == "JSContextRef" and sm.ptypes[1].to_s == ct # object method prepend context and self
        if sm.pnames.length == 2
          @co.puts desc_params(4,[],sm,2)
          
          @co.puts "    def #{prefix}#{sm.symbol}()"
          if @in_iface.is_module
            @co.puts "      res = #{@lib.lib_name}::Lib.#{f.name}(context,self)"
          else
            @co.puts "      res = super(context,self)"
          end
        else
          pnames = handle_params sm,f,2
          @co.puts desc_params(4,pnames,sm,2)
          
          @co.puts "    def #{prefix}#{sm.symbol}(#{pnames.join(",")})" 
          write_cast_param_code(sm,2)
          if @in_iface.is_module
            @co.puts "      res = #{@lib.lib_name}::Lib.#{f.name}(#{sm.pnames[2..sm.pnames.length-1].join(",")})"
          else
            @co.puts "      res = super(context,self,#{sm.pnames[2..sm.pnames.length-1].join(",")})" 
          end
        end
      else
        pnames = handle_params sm,f,0
        @co.puts desc_params(4,pnames,sm)
        
        @co.puts "    def #{prefix}#{sm.symbol}(#{pnames.join(",")})"
        write_cast_param_code(sm,0)
        if @in_iface.is_module
          @co.puts "      res = #{@lib.lib_name}::Lib.#{f.name}(#{pnames.join(",")})"
        else
          @co.puts "      res = super(#{sm.pnames.join(",")})" 
          if ctor
            @co.puts "      wrap = self.new(:pointer=>res)"
            @co.puts "      wrap.context = ctx" if pnames.index("ctx")
            @co.puts "      return wrap"   
          end
        end
      end
    else
      fail "non iface method in lib! (more than one iface in header)"
    end   
      
    case sm.return_type.split(" ").last
      when "JSValueRef"
        @co.puts """
    
      val_ref = JS::Value.from_pointer_with_context(context,res)
      ret = val_ref.to_ruby
      if ret.is_a?(JS::Value)
        return check_use(ret) || is_self(ret) || ret
      else
        return check_use(ret) || ret
      end
    
        """
      when "JSObjectRef"
        if sm.symbol.to_s == "get_global_object"
          @co.puts "      context = self"
        end 
        @co.puts "      return check_use(res) || JS::Object.from_pointer_with_context(context,res)"
      when "JSGlobalContextRef"
        # not doing auto cast  
      when "JSContextGroupRef"
        # not doing auto cast 
      when "JSPropertyNameArrayRef"
        @co.puts "      return JS::PropertyNameArray.new(res)"
    else
      case sm.return_type.split(" ").last
        when "JSStringRef"
          @co.puts "      return JS.read_string(res)"
      else
        @co.puts "      return res"
      end
    end unless cls
    
    @co.puts "    end"
  end
  
  def build_iface_function sm,f
     build_function sm,f,true
  end 
  
  def build_ctor sm,c
     build_function sm,c,true,true
  end
end
