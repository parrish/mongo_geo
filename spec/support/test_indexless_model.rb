class TestIndexlessModel
  include MongoMapper::Document
  plugin GeoSpatial
  key     :name,  String
  geo_key :coords, Array
end
