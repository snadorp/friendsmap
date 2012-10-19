class City < ActiveRecord::Base
  attr_accessible :id, :latitude, :longitude, :name
end
