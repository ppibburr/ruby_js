class Object
  alias :init :initialize
  def initialize(*o,&b)
      init *o,&b
 
      ObjectSpace.define_finalizer( self, self.class.finalize(self.class) )
  end
  def self.finalize(name)
    proc { p name }
  end
end
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
    @button = Button.new(self,'Search')
    @button.style['max-width'] = '100px'
    self.style['min-height'] = '26px'
    self.style['max-height'] = '26px'

  end
end
Rwt::App.run do |app|
  # runs in an preload
  app.images[:test] = "http://google.com/favicon.ico"
  app.images[:google] = "https://www.google.com/images/srpr/logo3w.png"

  app.onload do
    body = app.document.body
    panel = Panel.new body
    panel.height = "100%"
    vb = VBox.new panel
    vb.height = "100%"

    sb = SearchBar.new(vb)
    $sl = SearchList.new(vb)
    dl = DownloadList.new(vb)
    d = []
    3.times do
      d << ["1","2","3"]
    end
    $sl.set_data d
    sb.button.on :click do
      query = sb.entry.text
      GS.search(query) do |r|
        results = r.response.result
        dat = results.map do |q| q.map do |e| e.to_s end end
        QUE << [:search,dat]
      end if query != ""
      nil
    end
    
    sb.flex 0
    $sl.flex 50
    dl.flex 50
   # $sl.set_data [["a","b","c"],["1","2","3"],["x","y","z"]]
    DRb.start_service
    Thread.abort_on_exception = true
    GS = DRbObject.new_with_uri($uri)
    QUE = []
  end

  GLib.timeout_add(200, 20,proc do
    Thread.pass
    QUE.each do |q|
      QUE.delete q
      $sl.set_data q[1] if defined?($sl) 
      
    end
    true
  end, nil,nil)
  GC.start
  app.display
end

