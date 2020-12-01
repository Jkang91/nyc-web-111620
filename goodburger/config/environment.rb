require 'bundler'
Bundler.require
# Get all the gems and make them accessible in our code

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
ActiveRecord::Base.logger = nil

require_all 'lib'
# All the files within the lib folder should be accessible
