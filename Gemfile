source 'https://rubygems.org'

# Bundle edge Rails instead: 
# gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.3'

gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 4.0.0'
  
  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'
  
  # Use CoffeeScript for .js.coffee assets and views
  gem 'coffee-rails', '~> 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
end

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-validation-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'sufia', "~> 3.7.2"
#gem 'sufia'
# required to handle pagination properly in dashboard. See https://github.com/amatsuda/kaminari/pull/322
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'  
gem 'jettywrapper', "~> 1.5.0"
#gem 'jettywrapper'
#gem 'hydra-collections'

gem 'font-awesome-sass-rails'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem "bootstrap-sass"
gem "devise"
gem "devise-guests", "~> 0.3"
gem 'devise-remote-user'
gem "unicode", :platforms => [:mri_18, :mri_19]

gem 'qa'

gem 'paperclip', '>=3.1.0'

gem 'rt-client'

group :development, :test do
  gem "rspec-rails"
  #gem 'jettywrapper', "~> 1.5.0"
  gem 'chronic'
  #gem "jettywrapper"
  gem "factory_girl_rails", "~> 4.2.1"
  gem 'capybara', '~>2.1.0'
#  gem "debugger"
end
