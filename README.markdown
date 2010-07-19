# mongo_geo

mongo_geo is a plugin for [MongoMapper](http://github.com/jnunemaker/mongomapper) that exposes the [GeoSpatial indexing features](http://www.mongodb.org/display/DOCS/Geospatial+Indexing) in MongoDb.

Currently, I'm only developing against Ruby 1.9.1 so other versions may be flakey.

## Usage
### On the model
		class TestAsset
		  include MongoMapper::Document
		  plugin GeoSpatial

		  geo_key :coords, Array
		end

### [Plucky](http://github.com/jnunemaker/plucky) style queries:
		TestAsset.where(:coords.near => [50, 50]).limit(10).to_a
		TestAsset.where(:coords.within => { "$center" => [[50, 50], 10] }).to_a				# "$center" => [center, radius]
		TestAsset.where(:coords.within => { "$box" => [ [45, 45], [55, 55] ] }).to_a		# [lower_left, top_right]

N.B. bounds queries are syntactically ugly at the moment and are likely to change soon

### geoNear and convenience methods
		nearby = TestAsset.near([50, 50], :num => 15, :query => { ... })
		nearby.average_distance						# average distance of all results from the target point
		nearby.first.distance						# distance of this result from the target
		TestAsset.first.distance_from([50, 50])		# distance from any point
Queries can be specified with the [ruby driver style finders](http://github.com/mongodb/mongo-ruby-driver/blob/master/examples/queries.rb)

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.
