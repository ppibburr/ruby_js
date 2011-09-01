namespace :build do
  task :run do
    sh %{mkdir -p lib/JS/ffi}
    sh %{mkdir -p lib/JS/webkit}
    sh %{mkdir -p lib/JS/resources}    
    sh %{cd src && ruby js_define.rb}
    sh %{cd tools && ruby hd.rb}
    sh %{cp -rf src/hard_code/resources/* lib/JS/resources/}
  end
end

desc "Builds the library (.lib/)"
task :build => 'build:run'
