require 'rubygems'
require 'pry'

class PryJack
  class OutBuffer
    def << x
      $stdout.print x
    end
  end
  
  class << self
    attr_accessor :pry
  end

  attr_reader :pry_input,:pry_output,:_input,:_output
  def initialize
    rd,wr = IO.pipe
    rd2,wr2 = IO.pipe

    Pry.config.input = @pry_input = rd
    Pry.config.output = @pry_output = wr2
    
    @_input = wr
    @_output = rd2

    class << rd
      alias :_rl :readline
      attr_accessor :out_buffer
      def readline x
        out_buffer << x.to_s
        q=_rl()
        q
      end
    end
    
    class << wr2
      alias :_puts :puts
      attr_accessor :out_buffer
      def puts x=""
        out_buffer << x
      end
    end
    
    wr2.out_buffer = rd.out_buffer = OutBuffer.new
  end
  
  def run
    Thread.new do
      loop do
        until c = gets.chomp
        end
        input c
      end
    end 
  end
  
  def input x
    _input.puts x
  end
  
  def pry(obj=binding)
	Thread.new do
	  obj.pry
	end
	
  	until PryJack.pry;end
	run()

  end
end


class Pry
  alias :_init :initialize
  def initialize *o,&b
    _init *o,&b
    PryJack.pry = self
  end
end

if __FILE__ == $0
  pj = PryJack.new
  pj.pry
end


