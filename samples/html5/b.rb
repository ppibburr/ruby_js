CMD = "ruby -wc -e"
buffer = []
while c = gets.chomp
  buffer << c
  if system((CMD+"\"#{c=buffer.join("\n")}\""))
    p eval c
    buffer = []
  end
end
