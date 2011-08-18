
#       sugar.rb
             
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
class Sugar
  require 'fileutils'
  class Method
    attr_accessor :symbol,:pnames,:ptypes,:return_type,:param_descs,:array_params,:c_symbol,:method_notes,:param_defaults
  end

  attr_accessor :params_may_be_nil
  def initialize
    @params_may_be_nil = {}
    @param_defaults = {}
    @method_notes = {}
  end

  def desc_params idnt,names,sm,o=0
    types = sm.ptypes[o..sm.ptypes.length-1]
    names=names.clone
    if doc=@in_iface.documented[sm.c_symbol.to_s]
      buff = []
      if nt=@method_notes[sm.c_symbol.to_s.to_sym]
        buff << " "*idnt+"# "+nt
      end      
      
      if a=doc['abstract']
        @lib.typedefs.each_pair do |this,is|
          a=a.gsub("#{this.to_s.gsub("Ref",'')}","#{this.to_s.gsub("Ref",'').gsub(/^JS/,"JS::")}")
        end
        buff << " "*idnt+"# "+a+"\n#{" "*idnt}#"
      end
      
      if d=doc['discussion']
        # d.split("\n") do |l|
        #   buff << " "*idnt+"# "+l
        # end
      end
      
      if pms=doc['params']
        opt_pary = []
        cb = nil
        names.each_with_index do |n,i|
          if n =~ /\= nil/
            opt_pary << n
            names[i] = n.gsub(" = nil",'')
          end
          
          if n =~ /\&/
            cb = n.gsub("&","")
            names[i] = cb
          end
        end
        
        pms.each_pair do |n,d|
          next if !names.index(n)
          t= ruby_from_type(u=types[names.index(n)])
          
          if d =~ rx=Regexp.new("A #{k=u.gsub("Ref",'')} array")
            t = 'Array' 
            d = d .gsub(rx,"An Array of #{k}'s")
          end
          @lib.typedefs.each_pair do |this,is|
            d=d.gsub("#{this.to_s.gsub("Ref",'')}","#{this.to_s.gsub("Ref",'').gsub(/^JS/,"JS::")}")
          end
          #if opt_pary.index(n)
          #end
          d=d.gsub("NULL",'nil')
          if cb == n
            t = 'Proc'
          end
          buff << " "*idnt+"# @param [#{t}] #{n} "+d
        end
      end
      
      if r=doc['result']
        @lib.typedefs.each_pair do |this,is|
          r=r.gsub("#{this.to_s.gsub("Ref",'')}","#{this.to_s.gsub("Ref",'').gsub(/^JS/,"JS::")}")
        end
        buff << " "*idnt+"# @return [#{ruby_from_type(sm.return_type)}] "+r
      end
      buff.join("\n")
    else
      ""
    end
  end

  def add_method_note csym,val
    @method_notes[csym] = val
  end
  
  def add_param_default csym,idx,val
     a=@param_defaults[csym] ||= []
     a << [idx,val]
  end

  def ruby_from_type t
    n=@lib.ifaces.find {|i| i.c_type_name.to_s == t.to_s.gsub(":",'')}
    return "#{@lib.lib_name}::#{n.ruby_name}" if n
    case t.to_s.to_sym
      when :pointer
        'FFI::Pointer'
      when :unsigned
        'Integer'
      when :bool
        'boolean'
      when :void
        'nil'
      when :string
        'String'
      when :size_t
        'Integer'
      when :int
        'Integer'
      when :double
        'Float'
    else
      t.to_s
    end
  end


  def open_lib 
    @lo = File.open(File.join(@lib.target,"#{@lib_name}.rb"),'w')
    @lo.puts 'require "rubygems"'
    @lo.puts 'require "ffi"'
    @lo.puts "module #{@lib_name}"
    @lo.puts "  require File.join(File.dirname(__FILE__),'#{@lib.lib_name}','ffi','lib')"
    
    @lib.ifaces.each do |i|
      @lo.puts "  require File.join(File.dirname(__FILE__),'#{@lib.lib_name}','#{i.ruby_name}')"
    end
    
    @lib.hard_code.each do |hc|
      @lo.puts "  require File.join(File.dirname(__FILE__),'#{@lib_name}','#{hc[0]}')"
      if !File.exists?(File.join(hc[1],hc[0]+".rb"))
        File.open(File.join(@lib.target,@lib.lib_name,hc[0]+".rb"),'w') {|f| f.puts "module #{@lib.lib_name}\n\nend"}
      else
        FileUtils.cp(File.join(hc[1],hc[0]+".rb"),File.join(@lib.target,@lib.lib_name,hc[0]+".rb"))
      end
    end
    
    @lib.opt_req.each do |orf|
      FileUtils.cp(orf,File.join(@lib.target,@lib.lib_name,File.basename(orf)))
    end
  end
  
  def open_iface i
    @in_iface = i
    @co = File.open(File.join(@lib.target,@lib.lib_name,"#{i.ruby_name}.rb"),'w')
    if !i.is_module
      @co.puts "module #{@lib_name}"
      @co.puts "  class #{i.ruby_name} < #{@lib_name}::Lib::#{i.ruby_name}"
      i.includes.each do |m|
        @co.puts "    include #{m}"
      end
      
      @co.puts """
    class << self
      alias :real_new :new
    end  
      
    def self.new *o
      if o[0].is_a? Hash and o[0][:pointer] and o.length == 1
        real_new o[0][:pointer]
      else
        return #{@lib.lib_name}::#{@in_iface.ruby_name}.#{@in_iface.ctor_method}(*o)
      end
    end
      """  if @in_iface.ctor_method    
    else
      @co.puts "module #{@lib_name}"
      @co.puts "  module #{i.ruby_name}"   
    end
  end
  
  def close_lib
    @lo.puts "end"
    @lo.close
  end
  
  def close_iface
    @co.puts "  end"
    @co.puts "end"
    @co.close
  end
  
  def build_ctor sm,c

  end
  
  def build_iface_function sm,f
    
  end
  
  def build_function sm,f
  
  end
end
