require './rwt'
Rwt::App.run do |app|
  app.onload do
    body = app.document.body
    vb = VBox.new body
    hb = HBox.new vb
    a = TextBox.new hb,open('rwt.rb').read
    b = TextBox.new hb,open('rwt.rb').read
    a.flex 50
    b.flex 50 
    hb.flex 90
    Button.new(vb,'ffff').flex 10
  end
  app.display
end
