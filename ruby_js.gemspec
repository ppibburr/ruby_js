Gem::Specification.new do |s|
  s.name = "ruby_js"
  s.version = "0.0.09"
  s.date = Date.today.to_s

  s.summary = "FFI-based bindings to JavaScript in WebKit"

  s.authors = ["Matt Mesanko"]
  s.email = ["tulnor@linuxwaves.com"]
  s.homepage = "http://www.github.com/ppibburr/ruby_js"
  s.has_rdoc = 'yard'
  s.rdoc_options = ["--main", "README.rdoc"]

  s.files = Dir['{lib,test,tasks,samples}/**/**/*', "*.rdoc", "Rakefile"] & `git ls-files -z`.split("\0")
  #s.extra_rdoc_files = ["README.rdoc", "TODO.rdoc"]
  s.test_files = `git ls-files -z -- test`.split("\0")

  s.add_runtime_dependency(%q<ffi>, ["~> 1.0.8"])

  s.require_paths = ["lib"]
end
