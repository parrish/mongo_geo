require 'mongo_mapper'
require 'mongo_geo'

connection = Mongo::Connection.new '127.0.0.1', 27017
DB = connection.db 'mongo-geo'
MongoMapper.database = 'mongo-geo'

require_relative 'support/test_model'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  
  config.before(:suite) do
    DB['test_models'].remove
  end
end
