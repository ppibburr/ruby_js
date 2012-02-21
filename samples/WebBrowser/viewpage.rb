class ViewPage < Gtk::Frame
  attr_reader :view,:dock,:inspector
  def initialize
    super()
    @view = View.new()
    @inspector = Inspector.new(view.get_inspector())
    @dock = Gtk::Frame.new

    inspector.set_dock dock
    add vbox = Gtk::VBox.new

    scrolled_window = Gtk::ScrolledWindow.new()
    scrolled_window.hscrollbar_policy = Gtk::POLICY_AUTOMATIC
    scrolled_window.vscrollbar_policy = Gtk::POLICY_AUTOMATIC
    scrolled_window.add(view)
    scrolled_window

    vbox.pack_start scrolled_window,true,true
    vbox.pack_start dock,true,true
    
    signal_connect 'expose-event' do
      @inspector.on_page_show
      false
    end
  end
end
