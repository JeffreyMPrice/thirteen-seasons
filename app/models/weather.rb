class Weather
  include ActiveModel::Model

  attr_accessor :temperature, :dewpoint, :wind_direction, :wind_speed, :barometric_pressure,
                :visibility, :relative_humidity

  def ==(other)
    other.is_a?(Weather) &&
      temperature == other.temperature &&
      dewpoint == other.dewpoint &&
      wind_direction == other.wind_direction &&
      wind_speed == other.wind_speed &&
      barometric_pressure == other.barometric_pressure &&
      visibility == other.visibility &&
      relative_humidity == other.relative_humidity
  end
end
