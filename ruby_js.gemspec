Gem::Specification.new do |s|
  s.name = "ruby_js"
<<<<<<< HEAD
  s.version = "0.1.2"
  #s.date = Time.now.to_s
=======
  s.version = "0.1.0"
  s.date = Time.now.to_s
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d

  s.summary = "FFI-based bindings to JavaScript in WebKit"

  s.authors = ["Matt Mesanko"]
  s.email = ["tulnor@linuxwaves.com"]
  s.homepage = "http://www.github.com/ppibburr/ruby_js"
  s.has_rdoc = 'yard'
  s.rdoc_options = ["--main", "README.rdoc"]

  s.files = Dir['{lib,test,tasks,samples}/**/**/*', "*.rdoc", "Rakefile"] & `git ls-files -z`.split("\0")
  p s.files
  #s.extra_rdoc_files = ["README.rdoc", "TODO.rdoc"]
  s.test_files = `git ls-files -z -- test`.split("\0")

  s.add_runtime_dependency(%q<ffi>, ["~> 1.0.8"])

  s.require_paths = ["lib"]
end
