module Rwt
  module Expandable
    def self.extended q
      raise RuntimeError.new("Object must respond_to? :shade_handle")
      Rwt::UI::Expandable.new(q.shade_handle,q)
    end
  end
end
