class Forecast
  include ActiveModel::Model

  attr_accessor :name, :start_time, :end_time, :is_daytime, :temperature, :temperature_unit, :short_forecast, :detailed_forecast
end
