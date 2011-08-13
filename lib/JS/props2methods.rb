module RubyJS
  def self.decamelize s
    while s =~ /([a-z])([A-Z])/
      s = s.gsub("#{$1}#{$2}","#{$1}_#{$2}")
    end
    s.downcase
  end
end

class JS::Object
  def method_missing s,*o
    if idx=(properties.index(s.to_s) or properties.map do |prop| RubyJS.decamelize(prop) end.index(s.to_s))
      self[properties[idx]]
    else
      super
    end
  rescue
    super
  end
end
