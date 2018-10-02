require 'bundler'

Bundler.require
require_all 'app'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
# ActiveRecord::Base.logger = nil
require_all 'lib'
