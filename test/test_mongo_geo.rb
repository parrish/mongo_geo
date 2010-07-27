require 'helper'

class TestMongoGeo < Test::Unit::TestCase
  context "Initializing a model" do
    setup do
      @asset1 = TestAsset.create(:coords => [50, 50])
      @asset2 = TestAsset.create(:coords => [60, 60])
      @asset3 = TestAsset.create(:coords => [70, 70])
    end

    should "create the 2d index" do
      assert_equal(TestAsset.geo_key_name, :coords)
      assert(TestAsset.collection.index_information['coords_2d'], "geo_key did not define the 2d index")
    end
    
    should "validate #geo_key type" do
      assert_raise(ArgumentError) { TestAsset.geo_key(:blah, Float) }
      assert_raise(RuntimeError) { TestAsset.geo_key(:no_more, Array) }
    end
    
    should "allow plucky queries using #near" do
      nearby = TestAsset.where(:coords.near => [45, 45]).to_a
      assert_equal(nearby.first, @asset1)
      assert_equal(nearby.last, @asset3)
    end
    
    should "allow plucky queries using #within" do
      nearby = TestAsset.where(:coords.within => { "$center" => [[45, 45], 10] }).to_a
      assert_equal(nearby, [@asset1])
    end
    
    should "allow geoNear style queries with #near" do
      nearby = TestAsset.near([45, 45], :num => 2)
      assert_equal(2, nearby.count)
      assert_equal(@asset1, nearby.first)
      
      assert(nearby.methods.collect{ |m| m.to_sym }.include?(:average_distance), "#near did not define average_distance")
      assert_equal(nearby.average_distance.class, Float)
      
      assert(nearby.first.methods.collect{ |m| m.to_sym }.include?(:distance), "#near did not define distance on each record")
      assert_equal(nearby.first.distance.class, Float)
    end
    
    should "perform a simple #distance_from calculation" do
      assert(@asset1.methods.collect{ |m| m.to_sym }.include?(:distance_from), "GeoSpatial::InstanceMethods were not included")
      assert_equal(Math.sqrt(2), @asset1.distance_from([51, 51]))
      assert_raise(ArgumentError) { @asset1.distance_from(51) }
      
      TestAsset.collection.drop_indexes
      TestAsset.collection.remove
    end
  end
end
