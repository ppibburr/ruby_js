require '../lib/slc5hmi'

class HanleyClient < Client
  attr_accessor :session,:tl,:ready,:doc,:trend
  def initialize
  end
  
  def connect addr
    super addr
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
    
    o=doc.get_elements_by_class_name('data')  
    for i in 0..o.length-1
      o.item(i).className = "data"
    end  

  end
  
  def disconnect
    super
    
    [:host,:error,:connid,:tns,:device,:mode].each do |k|
      @session.send "#{k}=",'null'
    end
    
    [:host,:error,:connid,:tns,:device,:mode].each do |k|
      doc.get_element_by_id(k.to_s).innerHTML="#{@session.send(k).to_s.strip}"
    end
 
    o=doc.get_elements_by_class_name.call('data')  
    for i in 0..o.length-1
      o.item(i).className = "data hide"
    end
    puts "STATUS: closed comms"
  rescue => e
    puts "STATUS: comms dead"
  end
  
  def update
    return unless super
    
    @trend.update
    
    [:host,:error,:connid,:tns,:device,:mode].each do |k|
      doc.get_element_by_id(k.to_s).innerHTML="#{@session.send(k).to_s.strip}"
    end
    
    @tl.tags.each_pair do |k,t|
      next if t.name == "state"
      doc.get_element_by_id(k+"_value").innerHTML = t.value.to_s
    end
    
    if @tl.tags['state'].value > 0
      doc.get_element_by_id('state').innerHTML = "ALARM!!!"  
      doc.get_element_by_id('state').className = "alarm" 
    else
      doc.get_element_by_id('state').innerHTML = "OK" 
      doc.get_element_by_id('state').className = "normal" 
    end
  end
end

w = Gtk::Window.new "Scrubber Monitor"
w.set_size_request 900,650
v = WebKit::WebView.new
w.add v
w.show_all


v.load_html_string(DATA.read,'')
client = HanleyClient.new

v.signal_connect('load-finished') do |wv,f|
  begin
    client.disconnect
  rescue
  end
  
  client.connect "192.1.168.20"
  run_loop client
  
  doc = f.get_global_context.get_global_object.document
  client.doc = doc
  
  temp = [:Inlet_Temp,:Exhaust_Temp,:Vessel_Temp]
  temp.each do |t|
    tr = doc.createElement('tr')
    par = doc.get_element_by_id('temp')
    par.appendChild(tr)
    label = doc.createElement('td')
    label.className = "label"
    value = doc.createElement('td')
    value.className = "value"
    label.innerHTML = "#{t}"
    value.id = "#{t}_value"
    tr.append_child label
    tr.append_child value
  end
  
  temp = [:SumpPH,:Sump_LevelIN,:Sump_Conductivity]
  temp.each do |t|
    tr = doc.createElement('tr')
    par = doc.get_element_by_id('sump')
    par.appendChild(tr)
    label = doc.createElement('td')
    label.className = "label"
    value = doc.createElement('td')
    value.className = "value"
    label.innerHTML = "#{t}"
    value.id = "#{t}_value"
    tr.append_child label
    tr.append_child value
  end
  
  doc.get_element_by_id('close')['onclick']=proc do
    client.ready = nil
    sleep(0.5)
    client.disconnect
    Gtk.main_quit
    nil
  end

  doc.get_element_by_id('connect')['onclick']=proc do
    client.disconnect
    client.connect "192.1.168.20"
    client.ready = true
    nil
  end
  
  doc.get_element_by_id('disconnect')['onclick']=proc do
    client.disconnect
    nil
  end  
  
  ele = doc.getElementById('trend')
  
  client.trend=Trend.new(ele,860,270)   
  client.trend.interval = 3
  
  client.trend.add_pen "SumpPH",Pen.new(client.tl.tags['SumpPH'],'blue',8,0)
  client.trend.add_pen "Sump_LevelIN",Pen.new(client.tl.tags['Sump_LevelIN'],'red',40,0)
  client.trend.add_pen "Vessel_Temp",Pen.new(client.tl.tags['Vessel_Temp'],'green',300,0)
  
  client.ready = true
end

def run_loop client
  GLib::Idle.add do
    Thread.new do
      loop do
        sleep(1)
        begin
          client.update
        rescue => e
          break
        end
      end
      puts "STATUS: the loop has ended."
      client.disconnect
    end
    false
  end 
end

w.signal_connect('delete-event') do
  client.disconnect
  Gtk.main_quit
end

Gtk.main
client.session.comm.close
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
      .penLabel {
        position: absolute;
        z-index = 1000;
        background-color: gray;
        border-style: solid;
        border-color: #666;
        border-width: 1px;
        -webkit-border-top-left-radius: 0.5em;
        -webkit-border-bottom-left-radius: 0.5em;
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
