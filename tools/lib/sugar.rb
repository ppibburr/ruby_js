class Sugar
  require 'fileutils'
  class Method
    attr_accessor :symbol,:pnames,:ptypes,:return_type,:param_descs,:array_params,:c_symbol
  end

  attr_accessor :params_may_be_nil
  def initialize
    @params_may_be_nil = {}
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
      """      
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
