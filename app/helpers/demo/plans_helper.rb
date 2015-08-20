require 'haversine'


module Demo::PlansHelper

  def geo_distance(from_lat, from_lon, to_lat, to_lon)
    Haversine.distance(from_lat.to_f, from_lon.to_f, to_lat.to_f, to_lon.to_f)
  end

end
