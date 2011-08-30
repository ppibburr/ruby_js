require 'rubygems'
require 'ffi'
require 'JS'
require 'JS/webkit'
require 'JS/props2methods'

require 'abel'
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

class Pen
  attr_accessor :trend,:style,:min,:max,:tag
  def initialize t,style,u,l
    @max,@min = u,l
    @tag = t
    @style = style
    @x=nil
  end

  def update

    @x=@trend.width
    y = @trend.height - (((tag.value)/(max-min)) * @trend.height)
    trend.beginPath
    trend.cxt.strokeStyle = style
    trend.cxt.lineWidth=1
    @l ||= [trend.width-2,trend.height]
    c = y.ceil
    f = y.floor
    if y-f > c - y
      y = f
    elsif c-y > y-f
      y = c
    else
      y = f
    end
    trend.draw_line *[].push(*@l).push(@x-1,y)
    @l = [@x-2,y]
    trend.closePath  
    trend.cxt.lineWidth=1
  end
end

class Trend < Canvas
  attr_accessor :height,:pens,:width,:interval
  def initialize ctx,w,height
    super ctx
    @width = w
    @height = height
    @pens = {}
    draw_axi
    @interval = 1
    @cnt = 0
  end
  
  def add_pen k,pen
    @pens[k] = pen
    pen.trend=self
  end
  
  def shift
    if @id
      putImageData @id,11,0
      draw_axi
    end
  end
  
  def push
    @id = getImageData(12,0,width,height+29)
  end
  
  def update
    @cnt+= 1
    return unless @cnt == @interval
    @cnt = 0
    shift
    @pens.each_pair do |k,pen|
      pen.update
    end
    push
  rescue=>e
    p e
    puts e.backtrace
  end
  
  def draw_axi
    beginPath
    cxt.strokeStyle = '#000'
    draw_line 0,@height,@width,@height
    draw_line 0,0,0,@height
    closePath
    draw_rules
  end
  
  def draw_rules
    beginPath
    cxt['strokeStyle'] = "#cccccc"
    x,y,x1,y1 = 0,0,@width,0
    5.times do
      draw_line x,y,x1,y1
      y,y1 = y+@height/5.0,y1+@height/5.0
    end
    closePath
  end
end


class Session
  attr_accessor :tns,:connid,:comm,:error,:mode,:device,:tl,:poll_rate,:do_poll,:ui,:host
  def initialize(addr)
    @poll_rate = 1
    @comm = obj = ABEL::CommObject.new(addr)
    @tl = ABEL::TagLib.new(obj) 
  end
  
  def update
    poll
  end
  
  def init
    @host = comm.get_host
    comm.attach
    puts "STATUS: comms attached to #{host}"
  end
  
  def poll
    obj=comm
    
    if obj.ok? and obj.get_device_type == ABEL::CommObject::Type::SLC5
      @error = obj.get_error
      @tns = obj.get_tns
      @connid = obj.get_commid
      @mode = obj.get_mode
      @device = 'SLC5XX'
    else
      puts "Connection failed with error: #{obj.get_error}"
      obj.close
      raise
    end
  end
end

module ABEL
  class TagLib
    attr_accessor :tags,:comm
    class Tag
      attr_accessor :scale,:type,:file,:offset,:comm,:name
      def initialize name,type,file,offset
        @name,@type,@file,@offset = name,type,file,offset
      end
      
      def value
        r =nil
        case type
          when :integer
            r=comm.read_integer(file,offset)
          when :float
            r=comm.read_float(file,offset)
        end
        if r
          r * (scale || 1)
        end
      end
    end
    
    def initialize comm
      @comm = comm
      @tags = {}
    end
    
    def add_tag name,type,file,offset
      @tags[name]=t=Tag.new(name,type,file,offset)
      t.comm = comm
      t
    end
  end
end

class UI
  attr_accessor :session,:tl,:ready,:doc,:trend
  def initialize
  end
  
  def connect
    @session = Session.new("192.1.168.20")
    @session.init
    @tl = @session.tl
    
    tag = tl.add_tag "Inlet_Temp",:integer,"n7",0
    tag.scale = 0.1
    tag = tl.add_tag "Exhaust_Temp",:integer,"n7",1
    tag.scale = 0.1
    tag = tl.add_tag "Vessel_Temp",:integer,"n7",2
    tag.scale = 0.1
    
    tag = tl.add_tag "SumpPH",:integer,"n7",13
    tag.scale = 0.01
    tag = tl.add_tag "Sump_LevelIN",:integer,"n7",4
    tag.scale = 0.01
    tag = tl.add_tag "Sump_Conductivity",:integer,"n7",14
    tag.scale = 0.01
  
    tag = tl.add_tag "state",:integer,"n7",99   
    return if !doc
    
    o=doc.get_elements_by_class_name.call('data')  
    for i in 0..o.length-1
      o.item.call(i).className = "data"
    end  

  end
  
  def disconnect
    session.comm.close
    @ready = nil
    [:host,:error,:connid,:tns,:device,:mode].each do |k|
      @session.send "#{k}=",'null'
    end
    [:host,:error,:connid,:tns,:device,:mode].each do |k|
      doc.get_element_by_id.call(k.to_s).innerHTML="#{@session.send(k).to_s.strip}"
    end
 
    o=doc.get_elements_by_class_name.call('data')  
    for i in 0..o.length-1
      o.item.call(i).className = "data hide"
    end
    puts "STATUS: closed comms"
  rescue => e
    puts "STATUS: comms dead"
  end
  
  def update
    return if !ready
 
    @session.update
    
    @trend.update
    
    [:host,:error,:connid,:tns,:device,:mode].each do |k|
      doc.get_element_by_id.call(k.to_s).innerHTML="#{@session.send(k).to_s.strip}"
    end
    @tl.tags.each_pair do |k,t|
      next if t.name == "state"
      doc.get_element_by_id.call(k+"_value").innerHTML = t.value.to_s
    end
    if @tl.tags['state'].value > 0
      doc.get_element_by_id.call('state').innerHTML = "ALARM!!!"  
      doc.get_element_by_id.call('state').className = "alarm" 
    else
      doc.get_element_by_id.call('state').innerHTML = "OK" 
      doc.get_element_by_id.call('state').className = "normal" 
    end
  end
end

w = Gtk::Window.new "Scrubber Monitor"
w.set_size_request 900,650
v = WebKit::WebView.new
w.add v
w.show_all


v.load_html_string(DATA.read,'')
ui = UI.new

v.signal_connect('load-finished') do |wv,f|
  begin
    ui.disconnect
  rescue
  end
  ui.connect
  run_loop ui
  doc = f.get_global_context.get_global_object.document
  ui.doc = doc
  temp = [:Inlet_Temp,:Exhaust_Temp,:Vessel_Temp]
  temp.each do |t|
    tr = doc.createElement.call('tr')
    par = doc.get_element_by_id.call('temp')
    par.appendChild.call(tr)
    label = doc.createElement.call('td')
    label.className = "label"
    value = doc.createElement.call('td')
    value.className = "value"
    label.innerHTML = "#{t}"
    value.id = "#{t}_value"
    tr.append_child.call label
    tr.append_child.call value
  end
  
  temp = [:SumpPH,:Sump_LevelIN,:Sump_Conductivity]
  temp.each do |t|
    tr = doc.createElement.call('tr')
    par = doc.get_element_by_id.call('sump')
    par.appendChild.call(tr)
    label = doc.createElement.call('td')
    label.className = "label"
    value = doc.createElement.call('td')
    value.className = "value"
    label.innerHTML = "#{t}"
    value.id = "#{t}_value"
    tr.append_child.call label
    tr.append_child.call value
  end
  
  doc.get_element_by_id.call('close')['onclick']=proc do
    ui.ready = nil
    sleep(0.5)
    ui.disconnect
    Gtk.main_quit
    nil
  end

  doc.get_element_by_id.call('connect')['onclick']=proc do
    ui.disconnect
    ui.connect
    ui.ready = true
    nil
  end
  
  doc.get_element_by_id.call('disconnect')['onclick']=proc do
    ui.disconnect
    nil
  end  
  
  ele = doc.getElementById.call('trend')
  ui.trend=Trend.new(ele.getContext.call('2d'),860,270)   
  ui.trend.interval = 10
  ui.trend.add_pen "SumpPH",Pen.new(ui.tl.tags['SumpPH'],'blue',8,0)
  ui.trend.add_pen "Sump_LevelIN",Pen.new(ui.tl.tags['Sump_LevelIN'],'red',40,0)
  ui.trend.add_pen "Vessel_Temp",Pen.new(ui.tl.tags['Vessel_Temp'],'green',300,0)
  ui.ready = true
end

def run_loop ui
  GLib::Idle.add do
    Thread.new do
      loop do
        sleep(1)
        begin
          ui.update
        rescue => e
          break
        end
      end
      puts "STATUS: the loop has ended."
      ui.disconnect
    end
    false
  end 
end

w.signal_connect('delete-event') do
  ui.disconnect
  Gtk.main_quit
end

Gtk.main
ui.session.comm.close
__END__
<!doctype html>
 <html>
   <head>
     <title> Scrubber Monitor </title>
     <style type='text/css'>
      .label {
        background-color: #cecece;
        color: #000000;
        border-width: 1px;
        border-style: solid;
        border-color #666;
      }
      .value {
        background-color: gray;
        color: #000;
        border-width: 1px;
        border-style: solid;
        border-color #666;  
      }
      .data {
        display: normal;      
      }
      .hide {
        display: none;
      }
      .link {
        color: blue;
        cursor: pointer;
      }
      .normal {
        color: white;
        background-color: green;
      }
      .alarm {
        color: black;
        background-color: red;
      }
      .chart {
        border-style: solid;
        border-color: #666;
        border-width: 1px;
        background-color: #fff;
      }
      #trend {
        
        
      }
     </style>
   </head>
   <body style="background-color: silver;">
     <table>
       <tr>
         <td class=label> host </td>
         <td class=value id=host> null</td>
         <td class=label> connid </td>
         <td class=value id=connid> null</td>
         <td class=label> error </td>
         <td class=value id=error>null </td>
       </tr><tr>
         <td class=label> device </td>
         <td class=value id=device> null</td>
         <td class=label> mode </td>
         <td class=value id=mode>null</td>  
         <td class=label> tns </td>
         <td class=value id=tns> null</td>
       </tr>
     </table>
     <br><br><h>
     <table class data>
     <tr>
     <td>
     <table class=data id=temp>
      <tr><td> Degrees Farienhiet</td></tr>
     </table>
     </td><td>
      <table class=data id=sump>
      <tr><td>Sump Info</td></tr>
     </table>    
     </td>
     </tr>
     </table>
     <br>
     <span class=label>Scrubber status:</span>
     <span class=normal id=state>null</span>
     <br>
     <br>
     <div class=chart>
       <canvas id=trend width=900 height=300>
       </canvas>
     </div>
     <br>
     <br>
     <span class=link id=close>Close</span>
     <span class=link id=disconnect>Disconnect</span> 
     <span class=link id=connect>Connect</span>
   </body>
</html>
