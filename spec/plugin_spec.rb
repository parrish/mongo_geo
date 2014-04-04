require 'spec_helper'

describe TestModel do
  before(:all) do
    TestModel.create name: 'test1', coords: [50, 50]
    TestModel.create name: 'test2', coords: [60, 60]
    TestModel.create name: 'test3', coords: [70, 70]
  end
  
  let(:test1){ TestModel.where(name: 'test1').first }
  let(:test2){ TestModel.where(name: 'test2').first }
  let(:test3){ TestModel.where(name: 'test3').first }
  
  it 'should add symbol operators to plucky' do
    symbol_ops = Plucky::Extensions::Symbol.instance_methods
    :near.should be_in symbol_ops
    :within.should be_in symbol_ops
  end
  
  it 'should check for the 2d index' do
    TestModel.geo_key_name.should == :coords
    TestModel.collection.index_information['coords_2d'].should be_present
  end
  
  it 'should not create an index unless specified' do
    TestIndexlessModel.collection.index_information.should be_empty
  end
  
  it 'should validate the geo_key type' do
    expect{ TestModel.geo_key :foo, Float }.to raise_error{ ArgumentError }
    expect{ TestModel.geo_key :bar, Array }.to raise_exception{ RuntimeError }
  end
  
  it 'should query using near' do
    TestModel.where(:coords.near => [45, 45]).all.should == [test1, test2, test3]
    TestModel.where(:coords.near => [90, 90]).all.should == [test3, test2, test1]
  end
  
  it 'should query using within' do
    TestModel.where(:coords.within => { :$center => [ [45, 45], 10 ] }).all.should == [test1]
    TestModel.where(:coords.within => { :$center => [ [75, 75], 10 ] }).all.should == [test3]
    TestModel.where(:coords.within => { :$center => [ [100, 100], 10 ] }).all.should be_empty
  end
  
  context 'querying using geoNear' do
    let(:nearby){ TestModel.near([45, 45], num: 2) }
    let(:closest){ nearby.first }
    let(:furthest){ nearby.last }
    
    it 'should find nearby points' do
      nearby.should == [closest, furthest]
    end
    
    it 'should find the average distance of nearby points' do
      nearby.average_distance.should be_within(0.1).of 14.1
    end
    
    it 'should find the distance of each nearby point' do
      closest.distance.should be_within(0.1).of 7.0
      furthest.distance.should be_within(0.1).of 21.2
    end
  end
  
  it 'should calculate straight line distances' do
    test1.distance_from(test2.coords).should be_within(0.1).of 14.1
  end
  
  it 'should find the closest neighboring points' do
    test1.neighbors.should == [test2, test3]
  end
  
  it 'should find the closest neighboring point' do
    test1.neighbors(limit: 1).should == [test2]
  end
end
