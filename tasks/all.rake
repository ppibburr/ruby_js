desc """remove current build
      uninstall gem 
      rebuild library 
      build gem
      install gem
      remove local gem
      rake test"""
      
task :update do
  sh %{rake unbuild}
  sh %{sudo rake gem:remove}
  sh %{rake build}
  sh %{sudo rake gem}
end

desc "performs everything and tests everything"
task :update_and_test_all => :update do
  sh %{rake test}
end     
