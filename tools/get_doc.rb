def get_doc f
	meths = {}
	open = nil
	discuss = nil
	symbol_next = true
	File.read(f).split("\n").each do |l|
	  if symbol_next
		if l.strip=~/JS_EXPORT .*? (.*)\(.*\).*\;/
		  meths[$1] = open
		end
		open = nil
		symbol_next = nil
	  elsif l.strip =~ /@function/
		open = {'params'=>{}}
	  elsif open
		if l.strip =~ /@(param) (.*?) (.*)/
		  open['params'][$2]=$3
		elsif l.strip =~ /@([a-z]+) (.*)/
		  open[$1] = $2
		  if $1 == "discussion"
		    discuss = true
		  end
		elsif l.strip =~ /\*\//
		  symbol_next = true
		  discuss = nil
		elsif discuss
		  open['discussion'] = open['discussion'] + "\n" + l.strip
		end
	  end
	end
  meths
end
