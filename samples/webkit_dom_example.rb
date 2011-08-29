
#       webkit_dom_example.rb
             
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
require 'rubygems'
require 'ffi'

require File.join(File.dirname(__FILE__),'..','lib','JS')
require File.join(File.dirname(__FILE__),'..','lib','JS','props2methods')
require File.join(File.dirname(__FILE__),'..','lib','JS','webkit')


w = Gtk::Window.new()
v = WebKit::WebView.new

v.load_html_string("<!doctype html><html><body><canvas id=foo style=\"height: 500;\"></canvas></body></html>",nil)
w.add v
w.show_all


class Canvas
  def initialize context
    @context = context
    context.functions.each do |f|
      class << self; self;end.instance_exec do
        define_method f do |*o|
          cxt[f].call *o
        end
      end
    end
   
  end
  
  def plot x,y
	cxt['fillStyle']="blue";
	beginPath();
	arc(x,y,1,0,Math::PI*2,true);
	closePath();
	fill();  
  end
  
  def draw_line x,y,x1,y1
    moveTo x+10.5,y+10.5
    lineTo x1+10.5,y1+10.5
    stroke
  end
  
  def cxt
    @context
  end
end  

class Trend < Canvas
  def initialize *o
    super 
    cxt.strokeStyle="blue"
    draw_axi
    Thread.new do
      x = -1
      cnt = 0
      l = 0,0
      max,min = 8,-8.0
      height = 100.0
      loop do
        sleep(0.1);
        x = x+1
        y = ((rand(max-min)/(max-min))* height)
        beginPath
        cxt.strokeStyle = 'blue'
        draw_line *[].push(*l).push(x,y)
        closePath
        l = [x,y]
        x+=1
        down = false
        if cnt <= 30
          down = true
        end
        if cnt == 60
          cnt = 0
        end
        cnt+=1
        if down
          y+=1
        else
          y=y-1
        end
        
      end
    end 
  end
  
  def draw_axi
    beginPath
    cxt.strokeStyle = '#000'
    draw_line 0,100,100,100
    draw_line 0,0,0,100
    closePath
    fillText("8", 0, 15);
    fillText("0", 0, 65);
    fillText("-8", 0, 115);
    draw_rules
  end
  
  def draw_rules
    beginPath
    cxt['strokeStyle'] = "#cecece"
    x,y,x1,y1 = 0,80,100,80
    5.times do
      draw_line x,y,x1,y1
      y,y1 = y-20,y1-20
    end
    closePath
  end
end

def var q
 q
end
def ruby_do_dom ctx
  globj = ctx.get_global_object

  doc = globj['document']

  cv = doc.get_element_by_id.call('foo')
  c=doc.getElementById.call("foo");
  Trend.new(c.getContext.call('2d'))
end

w.signal_connect('delete-event') do 
  Gtk.main_quit
end

v.signal_connect('load-finished') do |v,f|
  ruby_do_dom(f.get_global_context)
end

Gtk.main
