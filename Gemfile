source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'

gem "acts-as-taggable-on"
gem "awesome_nested_set"  
gem "cancan"
gem "carrierwave"
gem 'devise'
gem "friendly_id", "~> 4.0.9"
gem "geocoder"
gem "haml"
gem 'jquery-rails'
gem 'kaminari'
gem 'geocoder'
gem "paper_trail"
gem "rabl"


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'compass-rails'
  gem 'zurb-foundation', '~> 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development do
	gem 'heroku_san'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  gem 'faker'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
end

group :staging do
  gem 'unicorn'
end

group :production do
	gem 'newrelic_rpm'
	gem 'unicorn'
end



