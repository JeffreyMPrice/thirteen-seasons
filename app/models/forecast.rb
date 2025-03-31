class Forecast
  include ActiveModel::Model

  attr_accessor :name, :start_time, :end_time, :is_daytime, :temperature, :temperature_unit, :short_forecast, :detailed_forecast

  def ==(other)
    other.is_a?(Forecast) &&
      name == other.name &&
      start_time == other.start_time &&
      end_time == other.end_time &&
      is_daytime == other.is_daytime &&
      temperature == other.temperature &&
      temperature_unit == other.temperature_unit &&
      short_forecast == other.short_forecast &&
      detailed_forecast == other.detailed_forecast
  end
end
