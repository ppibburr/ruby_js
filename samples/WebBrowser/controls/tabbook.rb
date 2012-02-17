run = nil
if __FILE__ == $0
  require "JS/html5"
  run = true
end
class TabBook < Gtk::Notebook
  class Label < Gtk::HBox
    attr_reader :button,:label,:icon
    def initialize text=""
      super false, 5
      @label = Gtk::Label.new text
      @button = Gtk::Button.new "x"
      @button.set_relief Gtk::RELIEF_NONE
      @icon = Gtk::Image.new
      pack_start @icon,false,false
      pack_start label,true,false
      pack_end button,false,false
      @label.show
      @icon.show
      show
    end
  end
  
  def initialize
    super
    
    set_scrollable true
    
    append_page Gtk::Frame.new(),Gtk::Label.new("+")
    
    signal_connect "page-added" do |o|
      on_page_added *o
    end
    
    signal_connect "page-removed" do |o|
      on_page_removed(*o)
    end
    
    signal_connect_after "switch-page" do |*o|
      on_switch_page(*o)
    end
  end
  
  def on_page_added page,q,i
    if n_pages == 2
      set_page 0
      get_tab_label(get_nth_page(self.page)).button.hide()
    else
      get_tab_label(get_nth_page(self.page)).button.show() if self.page < n_pages - 1  
    end
  end
  
  def on_page_removed book,page,i
    if n_pages == 2
      set_page 0
      get_tab_label(get_nth_page(0)).button.hide()
    end
  end
  
  def set_tab_icon pg,pb
    get_tab_label(pg).icon.pixbuf = pb
  end
  
  def on_switch_page book,page,i
    if i == n_pages - 1
      if i == 0
        return unless n_pages > 1
      else
        add(create_page)
        set_page i
        return
      end
    end
    
    pages.find_all do |pg|
      pg != get_nth_page(self.page)
    end.each do |pg|
      get_tab_label(pg).button.hide() unless pg == get_nth_page(n_pages-1)
    end
    
    if n_pages > 2
      get_tab_label(get_nth_page(i)).button.show()
    else
      get_tab_label(get_nth_page(i)).button.hide()  
    end
  end
  
  def pages
    a = []
    for i in 1..n_pages
      a << get_nth_page(i-1)
    end
    a
  end
  
  def create_page
    
  end
  
  def set_tab_text pg,text
    get_tab_label(pg).label.text = text
  end
  
  def add pg,text=""
    insert_page n_pages-1,pg,l=Label.new(text)
    l.button.signal_connect("clicked") do
      i=page_num(pg)
      if i == n_pages-2
        set_page i-1
      end
      remove_page(i)
    end
    pg
  end
end

if run
	class MyBook < TabBook
	  def create_page
		pg = Gtk::Frame.new
		pg.show
		pg
	  end
	end

	w = Gtk::Window.new
	b = MyBook.new

	w.add b
	w.show_all

	b.add b.create_page,"test1"


	Gtk.main
end
