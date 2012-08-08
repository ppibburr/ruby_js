namespace :build do
  task :run do
    sh %{mkdir -p lib/JS/ffi}
    sh %{cd src && ruby js_define.rb}
    sh %{cd tools && ruby hd.rb}
    sh %{mkdir -p lib/JS/html5/resource}
<<<<<<< HEAD
    sh %{mkdir -p lib/JS/html5/helpers/gir_ffi}
    sh %{cp -rf src/hard_code/html5/resource/ lib/JS/html5/}
    sh %{cp src/hard_code/html5/app.rb lib/JS/html5/}
    sh %{cp src/hard_code/html5/helpers/gir_ffi/*.rb lib/JS/html5/helpers/gir_ffi}
=======
    sh %{cp -rf src/hard_code/html5/resource/ lib/JS/html5/}
    sh %{cp src/hard_code/html5/app.rb lib/JS/html5/}
>>>>>>> a2f3fdf4008feb3ba86c81e57fad2f27c1a59e6d
    sh %{cp src/hard_code/overides/String.rb lib/JS/String.rb} 
    sh %{cp src/hard_code/overides/js_hard_code.rb lib/JS/js_hard_code.rb} 
    sh %{cp src/hard_code/overides/ruby_object.rb lib/JS/ruby_object.rb} 
    sh %{cp src/hard_code/overides/ffi/lib.rb lib/JS/ffi/lib.rb} 
    sh %{cp src/hard_code/overides/ffi/base_object.rb lib/JS/ffi/base_object.rb} 
  end
end

desc "Builds the library (.lib/)"
task :build => 'build:run'
