namespace :build do
  task :run do
    sh %{mkdir -p lib/JS/ffi}
    sh %{mkdir -p lib/JS/webkit}
    sh %{cd src && ruby js_define.rb}
    sh %{cd tools && ruby hd.rb}
    sh %{cp -rf src/hard_code/webkit/*.rb lib/JS/webkit/}
  end
end

desc "Builds the library (.lib/)"
task :build => 'build:run'
