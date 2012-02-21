class StatusString < String
  def initialize str
    super
  end
  # Gtk::Statusbar#display wants object that respond_to?(:write)
  def write q
    self << q.to_s
  end
end
