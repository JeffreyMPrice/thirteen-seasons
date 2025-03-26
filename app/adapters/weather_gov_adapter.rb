require "weather_gov_api"

class WeatherGovAdapter
  def initialize
    @client = WeatherGovApi::Client.new(user_agent: "Thirteen Seasons, #{ENV["ADMIN_EMAIL"]}")
  end

  def current_weather(latitude, longitude)
    response = @client.current_weather(latitude: latitude, longitude: longitude)
    if response.success?
      @properties = response.data["properties"]
      Weather.new(
        # comes back as C, need to convert to F
        temperature: celsius_to_fahrenheit(extract_weather_component("temperature")),
        dewpoint: celsius_to_fahrenheit(extract_weather_component("dewpoint")),
        wind_direction: extract_weather_component("windDirection"),
        wind_speed: extract_weather_component("windSpeed"),
        barometric_pressure: extract_weather_component("barometricPressure"),
        visibility: extract_weather_component("visibility"),
        relative_humidity: extract_weather_component("relativeHumidity"),
      )
    else
      Rails.logger.error "Weather API request failed: #{response.body}"
      nil
    end
  end


  def forecast(latitude, longitude)
    response = @client.forecast(latitude: latitude, longitude: longitude)
    return [] unless response.success?

    periods = response.data["properties"]["periods"]
    periods.map do |period|
      Forecast.new(
        name: period["name"],
        start_time: period["startTime"],
        end_time: period["endTime"],
        is_daytime: period["isDaytime"],
        temperature: period["temperature"],
        temperature_unit: period["temperatureUnit"],
        short_forecast: period["shortForecast"],
        detailed_forecast: period["detailedForecast"]
      )
    end
  end

  private

  def extract_weather_component(type)
    @properties[type]["value"]
  end

  def celsius_to_fahrenheit(celsius)
    return nil if celsius.nil?
    (celsius * 9.0 / 5.0) + 32
  end
end
