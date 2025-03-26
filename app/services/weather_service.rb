class WeatherService
  def initialize(adapter: WeatherGovAdapter.new)
    @adapter = adapter
  end

  def current_weather(latitude, longitude)
    @adapter.current_weather(latitude, longitude)
  end

  def forecast(latitude, longitude)
    @adapter.forecast(latitude, longitude)
  end
end
