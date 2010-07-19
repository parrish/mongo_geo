require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mongo_mapper'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'mongo_geo'

connection = Mongo::Connection.new('127.0.0.1', 27017)
DB = connection.db('mongo-geo')
MongoMapper.database = "mongo-geo"

class TestAsset
  include MongoMapper::Document
  plugin GeoSpatial

  geo_key :coords, Array
end

class Test::Unit::TestCase
  def setup
    DB['assets'].remove
  end
end
