require '/home/ppibburr/git/ruby_js/tools/lib/ast'

REGXP = {
  :function => /(.*?) (.*?)\((.*)\);/,
  :class => /struct _WebKit(.*)Class/,
  :func_next => /WEBKIT_API (.*)/, 
}

class IFace
  attr_accessor :name,:functions,:ctors
  def initialize n
    @name = n
    @functions = []
    @ctors = []
  end
end

class Lib
  attr_accessor :ifaces
  def initialize
    @ifaces = []
  end
end
lib = Lib.new
Dir.glob("/usr/include/webkit-1.0/webkit/webkit*.h").each do |pth|
  iface = nil;func_next = nil
  buff = File.read(pth)
  buff.split("\n").each do |l|
    if l =~ REGXP[:class]
      o = $1
      break if $1 =~ /Class/
      iface = IFace.new(o)
      lib.ifaces << iface
    elsif l=~REGXP[:func_next] and iface
      func_next = f = Function.new(nil)
      type = $1.strip.gsub("*",'').split(" ").last
      f.result = Function::Return.new(type)
    elsif l =~ /^(.*) \((.*)\);/ and func_next and iface
      h={
        :sym=>$1, 
        :args=>$2
      }
      raise if !h[:sym]
      func_next.name = h[:sym].strip
      h[:args].split(",").each do |pair|
        if pair =~ /(.*) (.*)$/
          break if $1 == ""
          type = $1.strip.split(" ")
          name = $2.strip.gsub("*",'')
          p type
          type = type.last.gsub("*",'')

          func_next.add_parameter Function::Param.new(name,type)
          iface.functions << func_next
        end
      end
    end
  end
end

TYPES = [
  [/char/ , :string],
  [/int/ , :int],
  [/double/ , :float],
  [/float/ , :float],
  [/void/ , :void]
]

def q n
  o = n
  while o =~ /([a-z])([A-Z])/
    o = o.gsub("#{$1}#{$2}","#{$1}_#{$2}") 
  end
  o.downcase
end

lib.ifaces.each do |i|
  TYPES << ["WebKit"+i.name, :object]
  
  puts "class #{i.name}"
  i.functions.each do |f|
    alist = []
    f.params.each do |prm|
      
    end
    puts "  def #{f.name.gsub(t="webkit_#{q(i.name)}_","")}(#{alist})"
    puts "    "
    puts "  end"
    puts
  end
  puts "end" 
  puts
end
