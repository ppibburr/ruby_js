class ViewBook < TabBook
  attr_reader :browser
  def initialize parent
    super()
    @browser = parent
    signal_connect "switch-page" do |book,page,i|
      @browser.toolbar.set_view get_nth_page(i).view unless i == n_pages-1
    end
  end
  
  def get_active
    get_nth_page self.page
  end
  
  def pages
    a = super
    a.delete_at a.length-1
    a
  end
  
  def create_page
    pg = ViewPage.new()
    pg.show_all
    @browser.on_page_create(pg)
    pg
  end
  
  def add_page
    add create_page
  end
  
  def set_page pg
    self.page = pg.is_a?(Fixnum) ? pg : page_num(pg)
  end
  
  def set_page_by_view view
    set_page get_page_by_view(view) 
  end
  
  def get_page_by_view view
    pages.find do |pg| pg.view == view end
  end
end
