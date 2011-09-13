class Rwt::Size
  DEFAULT = eval(File.read('/home/ppibburr/git/ruby_js/samples/rwt_size_default.rb'))
end

class Rwt::Drawable
  def apply_default_size()
    own_class = CSS_CLASS
    if defined?(self.class::CSS_CLASS)
      own_class = self.class::CSS_CLASS
    end
    
    size = (Rwt::Size::DEFAULT[own_class.to_sym] || :default)
    size = Rwt::Size.get_size(size)
    
    set_size Rwt::Size.new().push(*size)
  end
end

class Rwt::Size
  def self.get_size(size)
    if size.is_a?(Symbol)
      get_size Rwt::Size::DEFAULT[size]
    else
      size
    end
  end
end
