
require '/home/ppibburr/rpcs'
require 'open-uri'
require './rwt'
require 'thread'


class SearchList < List
  def initialize *o
    super
    ca = []
    [:Song,:Artist,:ID].each do |hd|
      ca << Grid::Column.new("#{hd}")
    end
    set_cols ca
  end
end
class DownloadList < List
  def initialize *o
    super
    ca = []
    [:ID,:File,:State].each do |hd|
      ca << Grid::Column.new("#{hd}")
    end
    set_cols ca
  end
end
class SearchBar < HBox
  attr_reader :entry,:button
  def initialize *o
    super
    @entry = Input.new(self,'')
    @entry.style['width'] = '350px'
    flex 90
    @button = Button.new(self,'Search')
    @button.style['max-width'] = '100px'
    self.style['min-height'] = '26px'
    self.style['max-height'] = '26px'

  end
end
QUE = []
b = proc do
  p :yui
  true
end
class Que < Array
  def check
    while !empty?
      first.each_pair do |k,v|
        send k,v
      end
      shift
    end
  end
  def method_missing m,v
    p m
  end
end
class Timer
  def initialize ctx,&b
    globj = ctx.get_global_object
    i = globj['timers'].length
    c = nil
    @timer_func = JS::Object.new ctx do
        @timer = globj.setTimeout("timers[#{i}]()",1000);
        b.call if b and c
        c = true
    end
    globj['timers'].push @timer_func
  end
  def run
    @timer_func.call
  end
end
#GLib.timeout_add 200,100, b, nil,nil
Rwt::App.run do |app|
  # runs in an preload
  GirFFI.setup "JSCore"
  app.images[:test] = "http://google.com/favicon.ico"
  app.images[:google] = "https://www.google.com/images/srpr/logo3w.png"

  app.onload do
    body = app.document.body
    g= body.context.get_global_object
    g['timers']=[]
    body.height = '370px'
    panel = Panel.new body,nil,true
    #panel.height = "100%"
    vb = VBox.new body
    vb.height = "100%"
    
    sb = SearchBar.new(vb)
    $sl = SearchList.new(vb)
    dl = DownloadList.new(vb)
    d = []
    QUE = []
    300.times do
      d << ["1","2","3"]
    end
    QUE << [:search,d]
    sb.button.on :click do
      query = sb.entry.text
      GS.search(query) do |r|
        results = r.response.result
        dat = results.map do |q| q.map do |e| e.to_s end end
        QUE << [:search,dat]
      end if query != ""
      nil
    end
       $sl.load_indicator
   # $p = LoadingSpinner.new(panel)
   
    #$p.style.minHeight = 100
    
    #$p.style.minWidth = 100
    #$p.flex 0
e=nil
que = Que.new
que << {:foo=>1}
Thread.new do
  sleep(7)
  que << {:bar=>2}
end
Timer.new body.context do
  que.check
end.run
    sb.flex 0
    $p = Widget.new(body)
    $p.text = "ggg"
    
    $sl.flex 50
 #         $sl.load_indicator.show
    dl.flex 50
   # $sl.set_data [["a","b","c"],["1","2","3"],["x","y","z"]]
    #DRb.start_service
   # Thread.abort_on_exception = true
  #  GS = DRbObject.new_with_uri($uri)
    #QUE = []
  end
  GC.start
  app.display
 # $sl.set_data QUE[0][1]
end

