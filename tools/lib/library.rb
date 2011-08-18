
#       library.rb
             
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
class Library < IFace
  attr_accessor :ifaces,:manual_funcs,:lib_name,:target,:ffi_libs,:callbacks,:hard_code,:opt_req,:documented
  def initialize
    super
    @ifaces = []
    @manual_funcs = []
    @callbacks = []
    @param_overides = {}
    @ffi_libs = []
    @hard_code = []
    @opt_req = []
  end
  
  def attach f,prms,r
    @manual_funcs << [f,prms,r]
  end
  
  def force_param_type func,idx,ptype
    q = @param_overides[func] ||= {}
    q[idx] = ptype
  end
  
  def add_hard_code(*ary)
    @hard_code << ary
  end
  
  def add_optional_require f
    @opt_req << f
  end
  
  def typedef is,this
    typedefs[this] = is
  end
  
  def define
    super if source_header
    ifaces.each do |i|
      i.define
    end
  end
  
  def callback cb,params,ret
    @callbacks << {:symbol=>cb,:params=>params,:return=>ret}
  end
  
  def get_cb sym
    @callbacks.find {|cb| cb[:symbol] == sym}
  end
  
  def document_method idnt,i,f,pnames,ptypes

    if doc=i.documented[f.name.to_s]
      buff = []
      if a=doc['abstract']
        buff << " "*idnt+"# "+a+"\n#{" "*idnt}#"
      end
      
      if d=doc['discussion']
        d.split("\n") do |l|
          buff << " "*idnt+"# "+l
        end
      end
      
      if pms=doc['params']
        pms.each_pair do |n,d|
          t= ptypes[pnames.index(n)]
          buff << " "*idnt+"# @param [#{t}] #{n} "+d
        end
      end
      
      if r=doc['result']
        buff << " "*idnt+"# @return "+r
      end
      buff.join("\n")
    else
      ""
    end
  end
  
  def generate_iface_function_binding i,f,mo,io,cls = false
        prefix = ""
        if cls then prefix = "self." end
        
        ret = "#{get_type(f.result.c_type.split(" ").last)}".gsub("*",'').split(" ").last
        
        pnames = []
        params = []
        desc = []

        f.params.each_with_index do |p,idx|
          if p.name =~ /\[\]/ then p p.c_type ; end
          t=":#{get_type(p.c_type.split(" ").last)}".gsub("*",'').split(" ").last
          
          if h=@param_overides[f.name.to_s.to_sym]
            if h.has_key?(idx)
              t = ":"+h[idx].to_s
            end
          end
          
          params << t
          pnames << p.name
          desc << [p.name,t]
        end
        
        io.puts "\n"

        arrays = {}           
        pnames.each_with_index do |n,idx|
          if n =~ /(.*)\[\]/
            pnames[idx] = $1
            desc[idx] = [$1,"array of #{params[idx]}"]
            arrays[$1] = params[idx]
          end
        end

        # desc.each do |d|
        #  io.puts "      # @param #{d[0]} => #{d[1]}"
        # end
        io.puts document_method(6,i,f,pnames,params)
        #io.puts "      # retuen => #{ret}"
        
        io.puts "      def #{prefix}#{(rm=decamel(f.name.gsub(Regexp.new("^#{i.c_function_prefix}"),'')))}(#{pnames.join(",")})"
        
        sugar_meth = Sugar::Method.new
        sugar_meth.symbol = rm
        sugar_meth.param_descs = desc
        sugar_meth.pnames = pnames
        sugar_meth.ptypes = params
        sugar_meth.array_params = arrays
        sugar_meth.c_symbol = f.name
        sugar_meth.return_type = ret
        

        io.puts "        #{lib_name}::Lib.#{f.name}(#{pnames.join(",")})"
        io.puts "      end"        
        mo.puts "    attach_function :#{f.name},[#{params.join(",")}],:#{ret}"   
        
        return sugar_meth
  end
  
  def build sugar = nil
    sugar.open_lib if sugar
    mo = File.open(File.join(target,lib_name,'ffi','lib.rb'),'w')
    File.open(File.join(target,lib_name,'ffi','base_object.rb'),'w') {|f| f.puts """
module JS
  class BaseObject
    attr_accessor :pointer
    def initialize ptr
      @pointer = ptr
    end
    
    def to_ptr
      @pointer
    end
    
    def is_self ptr
      return nil if !ptr
      if ptr.respond_to?(:address) and self.pointer.address == ptr.address
        return self
      end
      
      return nil
    end    
  end
end

def check_use ptr
  nil
end
    
    """}
    
    mo. puts "module #{lib_name}"
    mo.puts "  module Lib"
    mo.puts '    require "#{File.dirname(__FILE__)}/base_object"'
    ifaces.each do |i|
      mo.puts "    require File.join(File.dirname(__FILE__),'#{i.ruby_name}')"
    end
    
    mo.puts "\n"
    mo.puts "    extend FFI::Library"
    mo.puts "    ffi_lib '#{ffi_libs.join(',')}'"
    
    mo.puts "\n"
    
    typedefs.each_pair do |k,v|
      mo.puts "    typedef :#{v},:#{k}"
    end
    
    mo.puts "\n"
    
    callbacks.each do |cb|
      mo.puts "    callback :#{cb[:symbol]},[#{cb[:params].map do |p| ":#{p}" end.join(",")}],:#{cb[:return]}"
    end    
    
    mo.puts "\n"
    
    manual_funcs.each do |f,prms,r|
      prms = prms.map do |p| ":#{p}" end
      mo.puts "    attach_function :#{f},[#{prms.join(",")}],:#{r}"
    end
    
    mo.puts "\n"
    
    ifaces.each do |i|
      sugar.open_iface i
      io = File.open(File.join(target,lib_name,'ffi',"#{i.ruby_name}.rb"),'w')
      io.puts "module #{@lib_name}\n  module Lib\n    class #{i.ruby_name} < #{@lib_name}::BaseObject"
      i.ctors.each do |c|
        sm=generate_iface_function_binding i,c,mo,io,true
        if c.is_a?(Constructor)
          sugar.build_ctor sm,c
        else
          sugar.build_iface_function sm,c
        end
      end
    
      i.functions.each do |f|
        sm=generate_iface_function_binding(i,f,mo,io) 
        sugar.build_function sm ,f 
      end
      
      io.puts "    end"
      io.puts "  end"
      io.puts "end"
      sugar.close_iface
    end
    mo.puts "  end"
    mo.puts "end"
    mo.close
    sugar.close_lib
  end
end
