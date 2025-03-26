class Weather
  include ActiveModel::Model

  attr_accessor :temperature, :dewpoint, :wind_direction, :wind_speed, :barometric_pressure,
                :visibility, :relative_humidity
end
