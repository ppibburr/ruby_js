if __FILE__ == $0
  require 'demo'
end

def run_demo_fixed
  parent = DemoRunner.get_target(__FILE__)
  size = [600,400]
  size = [-1,-1] if __FILE__ != $0
  wi = Rwt::Dow.new(parent,"Fixed Layout",:size=>size)
  wi.add b=Rwt::Container.new(wi) # b.get_rect defaults to 0,0,-1,-1 (left->0 absolute,top->0 absolute,width->available at b.show(),height->available at b.show())
  b.add l=Rwt::Label.new(b,"My rect is 0,0,200,20",:size=>[200,20],:position=>[0,0])
  l.style['background-color']='#cfcfcf'
  b.add l=Rwt::Label.new(b,"My rect is 0,20,200,20",:size=>[200,20],:position=>[0,20])
  l.style['background-color']='#ebebeb'
  b.add l=Rwt::Label.new(b,"My rect is 0,40,200,20",:size=>[200,20],:position=>[0,40])
  l.style['background-color']='#cfcfcf'
  b.add l=Rwt::Label.new(b,"My rect is 0,20,200,20",:size=>[200,20],:position=>[0,60])
  l.style['background-color']='#ebebeb'
  b.add l=Rwt::Label.new(b,"My rect is 0,40,200,20",:size=>[200,20],:position=>[0,80])
  l.style['background-color']='#cfcfcf'
  b.add l=Rwt::Label.new(b,"My rect is 0,20,200,20",:size=>[200,20],:position=>[0,100])
  l.style['background-color']='#ebebeb'
  b.add l=Rwt::Label.new(b,"My rect is 0,40,200,20",:size=>[200,20],:position=>[0,120])
  l.style['background-color']='#cfcfcf'
  
  def wi.show
    super
    #puts caller.join("\n");exit
  end
  if __FILE__ == $0
    wi.show
  else
    parent.add wi
  end
end

if __FILE__ == $0
  DemoRunner.run_standalone_demo(method(:run_demo_fixed))
else
  run_demo_fixed
end
