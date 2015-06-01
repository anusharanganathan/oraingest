namespace :ora do

  namespace :travis do
    desc "Prepare for Travis build"
    task :prepare => ['db:test:prepare', 'jetty:clean', 'jetty:config'] do
    end

    desc "Travis build"
    task :build => :prepare do
      ENV['environment'] = "test"
      jetty_params = Jettywrapper.load_config
      jetty_params[:startup_wait] = 60
      Jettywrapper.wrap(jetty_params) do
        Rake::Task['spec'].invoke
      end
    end
  end

end