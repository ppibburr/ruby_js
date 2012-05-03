

require 'open-uri'
require './rwt'
require 'thread'



class SearchList < List
  attr_reader :ld_que
  def initialize *o
    super
    ca = []
    widths=[240,100]
    
    [:Song,:Artist].each_with_index do |hd,i|
      ca << c=Grid::Column.new("#{hd}")
      c.width = widths[i]
    end
    
    set_cols ca
    
    on_cell_activate do |c|
      download(c['row'])  
    end
  end
  
  def set_loading
    super
    @ld_que.add :results do |v|
      set_data v
    end
  end
  
  def set_data v
    super
    set_loaded
  end
  
  def download di
    si = GrooveService.active_search_index
    p si,di,:idx
    GrooveService.download si.to_i,di.to_i
  end
end
class Library < List
  def initialize *o
    super
    ca = []
    widths=[300,40]
    [:File,:State].each_with_index do |hd,i|
      ca << c=Grid::Column.new("#{hd}")
      c.width = widths[i]
    end
    set_cols ca
    set_data q=GrooveService.library
    on_cell_activate do |c|
      play c['row']
    end
  end
  def set_player player
    @player = player
  end
  def play i
    file_name = @data[i][0]
    @player.open(File.join(GrooveService.lib_uri,file_name))
  end
end
class SearchBar < HBox
  attr_reader :entry,:button
  def initialize *o
    super
    @entry = Input.new(self,'',:search)
    @entry.style['width'] = '350px'
    @button = Button.new(self,'Search',:search)
    @button.style['max-width'] = '120px'
    self.style['min-height'] = '26px'
    self.style['max-height'] = '26px'
    self.style.marginBottom = '5px'
  end
end

module Rwt
  module Util
    class Timer
      attr_reader :interval,:timer_func,:timer,:t_index,:globj
      def initialize ctx,interval=30,&b
        @interval = interval
        @globj = ctx.get_global_object
      
        @t_index = globj['timers'].length
        c = nil
        
        @timer_func = JS::Object.new ctx do
          if !stopped?
          @timer = globj.setTimeout("timers[#{@t_index}]()",@interval);
          b.call if b and c
          c = true
          end
        end
        
        globj['timers'][@t_index] = @timer_func
      end
      def interval= i
        raise "Argument must be Numeric" unless i.is_a?(Numeric)
        @interval = i
      end
      def run
        raise "Timer removed" if removed?
        return if @timer
        @timer_func.call
        nil
      end
      def start
        raise "Timer removed" if removed?
        @stopped = false
        @timer_func.call
      end
      def stop
        raise "Timer removed" if removed?
        @stop = true
      end
      def stopped?
        !!@stop
      end
      def remove!
        return if removed?
        stop
        @globj['timers'][@t_index]=:undefined
        @timer_func = nil
        @timer = nil
        @removed = true
      end
      def removed?
        !!@removed
      end
    end
  
    class Que < Array
      attr_reader :callbacks,:timer
      def initialize ctx,i=30
        @callbacks = {}
        @timer = Timer.new(ctx,i) do
          self.check
        end
        super()
      end
      def add sym, &b
        @callbacks[sym] = b
      end
      def check
        raise "Que removed" if removed?
        return if empty?
          p a=shift,:hh
          a.each_pair do |k,v|
            if (cb=@callbacks[k]).respond_to?(:call)
              cb.call v
            elsif respond_to?(k)
              send(k,v)
            end
          end

      end
      def run
        raise "Que removed" if removed?
        @timer.run
      end
      def stop
        @timer.stop
      end
      def start
        @timer.start
      end
      def stopped?
        @timer.stopped?
      end
      def remove!
        @timer.remove!
      end
      def removed?
        @timer.removed?
      end
    end
  end
end
class RObject
  def set_loading
    @ld_que ||= Rwt::Util::Que.new context
    load_indicator
    @ld_que.add :load do |v|
      load_indicator.hide
    end
    @ld_que.run
  end
  def set_loaded
    @ld_que << {:load=>nil}
  end
  def que
    if !@que 
      @que = Rwt::Util::Que.new context
      @que.run
    end
    @que
  end
end

class GrooveUI
  attr_reader :search_bar,:search_list,:library
  def initialize body
    body.style.maxHeight = '370px'

    panel = Panel.new body,nil,true
    a=Acordion.new panel
    panel1 = AcordionPanel.new(a,"Search")
    panel2 = AcordionPanel.new(a,"Library") 
    vb = VBox.new panel1
    
    @search_bar = SearchBar.new(vb)
    @search_list = SearchList.new(vb)
    @library = Library.new(panel2)
    @player = Audio.new(panel2)
    
    search_bar.button.on :click do
      search_list.set_loading
      query = body.context.get_global_object.escape(search_bar.entry.text)
      if query != ""
        search_list.ld_que << {:results=>GrooveService.search(query)}
      end
      nil
    end

    search_bar.flex 0
    search_list.flex 50
    library.flex 50

    library.set_player @player
    library.play(0)
  end
end

class GrooveService
  @app_uri = "http://127.0.0.1:9955/app/GrooveService"
  @lib_uri = "http://127.0.0.1:9955/lib"
  class << self
    attr_reader :app_uri,:lib_uri
  end
  def self.search q
    request "search",q
  end
  def self.download si,i
    request "download",si.to_s,i.to_s
  end
  def self.library
    request "library"
  end
  def self.active_search_index
    request("active_search")["value"]
  end
  def self.request cmd,*args
    JSON.load(open(uri(cmd,*args)).read)
  end
  def self.uri(*a)
    File.join(@app_uri,*a)
  end
end

require 'json'

Rwt::App.run do |app|
  # runs in an preload
  GirFFI.setup "JSCore"
  app.images[:test] = "http://google.com/favicon.ico"
  app.images[:google] = "https://www.google.com/images/srpr/logo3w.png"
  app.images[:search] = "http://www.veryicon.com/icon/16/System/Must%20Have/Search.png"

  app.onload do
    body = app.document.body
    g= body.context.get_global_object

    g['timers']=[]
    GrooveUI.new body
  end
  GC.start
  app.display
end

