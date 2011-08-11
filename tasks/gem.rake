namespace :gem do
	desc "creates a rubygems .gem"
	task :build do
	  sh %{gem build ruby_js.gemspec}
	end

	desc "remove ruby_js-[version] installation from rubygems"
	task :remove do
	  sh %{gem uni ruby_js}
	end

    desc "installs the gem to rubygems"
	task "install" do
      sh %{gem i ruby_js*.gem}
	end
	
	desc "remove local ./ruby_js-*.gem"
	task :clean do
	  sh %{rm ruby_js*.gem}
	end
end

desc "builds and installs gem and removes local ./ruby_js-*.gem"
task :gem => ["gem:build","gem:install","gem:clean"]
