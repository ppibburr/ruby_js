namespace :build do
  task :run do
    sh %{mkdir -p lib/JS/ffi}
    sh %{cd src && ruby js_define.rb}
  end
end

desc "Builds the library (.lib/)"
task :build => 'build:run'
