module Demo::PlansHelper

  def geo_distance(from_lat, from_lon, to_lat, to_lon)
    GeoDistance::Haversine.geo_distance(from_lat, from_lon, to_lat, to_lon).kms.round(2)
  end

end
