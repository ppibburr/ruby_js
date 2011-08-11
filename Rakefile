task :test do
  sh %{cd test && ruby run_tests.rb}
end

task :default => :test

task :build do
  sh %{cd src && ruby js_define.rb}
end


