namespace :build do
  task :run do
    sh %{mkdir -p lib/JS/ffi/ext}
    sh %{cd src && ruby js_define.rb}
    sh %{cd src/c && gcc -I./ -lwebkitgtk-1.0 -shared -o JSRubyObjectClass.so JSRubyObjectClass.c}
    sh %{mv src/c/JSRubyObjectClass.so lib/JS/ffi/ext/JSRubyObjectClass.so}
  end
end

desc "Builds the library (.lib/)"
task :build => 'build:run'
