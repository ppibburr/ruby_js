module RubyJS
  def self.decamelize s
    while s =~ /([a-z])([A-Z])/
      s = s.gsub("#{$1}#{$2}","#{$1}_#{$2}")
    end
    s.downcase
  end
  
  def self.camelize s
    while s =~ /([a-z])\_([a-z])/
      s = s.gsub("#{$1}_#{$2}","#{$1}#{$2.upcase}")
    end
    s
  end
end

class JS::Object
  def method_missing sym,*o,&b
    sym = sym.to_s
    
    if sym =~ /(.*)=$/
      sym = $1
      is_setter = true
    end

    if is_setter
      self[sym] = o[0]
    elsif has_property(sym)
      self[sym]
    elsif has_property(q=RubyJS.camelize(sym))
      self[q]
    else
      super
    end
  rescue
    super
  end
end
