require 'mongo_mapper'

module Plucky
  module Extensions
    module Symbol
      def near
        SymbolOperator.new(self, 'near')
      end

      def within
        SymbolOperator.new(self, 'within')
      end
    end
  end
end

module GeoSpatial
  extend ActiveSupport::Concern
  
  module ClassMethods
    def geo_key(name, klass)
      unless [Array, Hash].include?(klass)
        raise(ArgumentError, "#{klass} is not a valid type for a geo_key\nUse either an Array(recommended) or a Hash")
      end
      
      if @geo_key_name.nil?
        key name.to_sym, klass
        ensure_index([[name, Mongo::GEO2D]])
        @geo_key_name = name
      else
        error = "MongoDB is currently limited to only one geospatial index per collection.\n"
        error += "geo_key #{name} was NOT added to #{self.name}"
        raise(RuntimeError, error)
      end
    end
    
    def geo_key_name
      @geo_key_name
    end
    
    def near(location, params = {})
      args = BSON::OrderedHash.new
      args[:geoNear] = self.collection.name
      args[:near] = location
      params.each_pair{ |key, value| args[key.to_sym] = value }
      
      raw = database.command(args)
      objects = raw["results"].collect{ |r| self.load(r["obj"]) }
      objects.instance_variable_set(:@raw, raw)
      
      objects.each.with_index do |obj, index|
        obj.instance_variable_set(:@distance, raw["results"][index]["dis"])
        def obj.distance
          @distance
        end
      end
      
      def objects.average_distance
        @raw["stats"]["avgDistance"]
      end
      
      objects
    end
  end

  def distance_from(pt)
    name = self.class.geo_key_name
    return nil if name.nil?
    raise(ArgumentError) unless [Array, Hash].include?(pt.class)
    
    loc = self.send(name)
    loc = loc.values if loc.is_a?(Hash)
    pt = pt.values if pt.is_a?(Hash)
    
    dx = loc[0] - pt[0]
    dy = loc[1] - pt[1]
    Math.sqrt((dx ** 2) + (dy ** 2))
  end
  
  def neighbors(opts = {})
    opts = {:skip => 0, :limit => 10}.merge(opts)
    location = self.class.geo_key_name.to_sym
    
    self.class.name.constantize.where(
      location.near => self.send(self.class.geo_key_name)
    ).skip(opts[:skip]).limit(opts[:limit] + 1).to_a.reject { |n| n.id == self.id }
  end
end

MongoMapper::Plugins.send :include, GeoSpatial