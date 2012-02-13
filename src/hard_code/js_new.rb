def make_class path = ""
  singleton = class << self
    self
  end
  
  klass = singleton.eval("class #{obj.split(".").last}")
  
  klass.class eval do
    def n
  end
  
