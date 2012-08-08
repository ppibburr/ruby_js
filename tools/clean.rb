Dir.chdir ".."
`git ls-files`.split("\n").each do |f|
  if !File.exist?(f)
    `git rm -r #{f}`
  end
end
`git add *`
`git commit -m "#{ARGV[0]||"..."}"`
`git push origin master`
