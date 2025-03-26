require 'rails_helper'

RSpec.describe WeatherGovAdapter do
  let(:adapter) { WeatherGovAdapter.new }
  let(:latitude) { 37.7749 }
  let(:longitude) { -122.4194 }
  let(:weather_client) { instance_double(WeatherGovApi::Client) }
  let(:weather_gov_response) do
    instance_double(WeatherGovApi::Response, success?: true, data: {
      "properties" => {
        "temperature" => { "value" => 8 },
        "dewpoint" => { "value" => 2 },
        "windDirection" => { "value" => 270 },
        "windSpeed" => { "value" => 7.56 },
        "barometricPressure" => { "value" => 102170 },
        "visibility" => { "value" => 16090 },
        "relativeHumidity" => { "value" => 65.848771416258 }
      }
    })
  end
  let(:expected_weather) do
    Weather.new(
      temperature: 46.4,
      dewpoint: 35.6,
      wind_direction: 270,
      wind_speed: 7.56,
      barometric_pressure: 102170,
      visibility: 16090,
      relative_humidity: 65.848771416258,
    )
  end
  let(:forecast_response) do
    instance_double(WeatherGovApi::Response, success?: true, data: {
      "properties" => {
        "periods" => [
          {
            "name" => "Tonight",
            "startTime" => "2023-10-27T18:00:00-07:00",
            "endTime" => "2023-10-28T06:00:00-07:00",
            "isDaytime" => false,
            "temperature" => 50,
            "temperatureUnit" => "F",
            "shortForecast" => "Mostly Clear",
            "detailedForecast" => "Mostly clear, with a low around 50."
          },
          {
            "name" => "Saturday",
            "startTime" => "2023-10-28T06:00:00-07:00",
            "endTime" => "2023-10-28T18:00:00-07:00",
            "isDaytime" => true,
            "temperature" => 65,
            "temperatureUnit" => "F",
            "shortForecast" => "Sunny",
            "detailedForecast" => "Sunny, with a high near 65."
          }
        ]
      }
    })
  end

  before do
    allow(WeatherGovApi::Client).to receive(:new).and_return(weather_client)
    allow(weather_client).to receive(:current_weather).and_return(weather_gov_response)
    allow(weather_client).to receive(:forecast).and_return(forecast_response)
  end

  describe "#current_weather" do
    it "returns the current weather" do
      weather = adapter.current_weather(latitude, longitude)

      expect(weather.temperature).to eq(46.4)
      expect(weather.dewpoint).to eq(35.6)
      expect(weather.wind_direction).to eq(270)
      expect(weather.wind_speed).to eq(7.56)
      expect(weather.barometric_pressure).to eq(102170)
      expect(weather.visibility).to eq(16090)
      expect(weather.relative_humidity).to eq(65.848771416258)
    end
  end

  describe "#forecast" do
    it "returns the forecast" do
      forecast = adapter.forecast(latitude, longitude)

      expect(forecast.count).to eq(2)
      expect(forecast.first.name).to eq("Tonight")
      expect(forecast.first.start_time).to eq("2023-10-27T18:00:00-07:00")
      expect(forecast.first.end_time).to eq("2023-10-28T06:00:00-07:00")
      expect(forecast.first.is_daytime).to eq(false)
      expect(forecast.first.temperature).to eq(50)
      expect(forecast.first.temperature_unit).to eq("F")
      expect(forecast.first.short_forecast).to eq("Mostly Clear")
      expect(forecast.first.detailed_forecast).to eq("Mostly clear, with a low around 50.")
      expect(forecast.second.name).to eq("Saturday")
      expect(forecast.second.start_time).to eq("2023-10-28T06:00:00-07:00")
      expect(forecast.second.end_time).to eq("2023-10-28T18:00:00-07:00")
      expect(forecast.second.is_daytime).to eq(true)
      expect(forecast.second.temperature).to eq(65)
      expect(forecast.second.temperature_unit).to eq("F")
      expect(forecast.second.short_forecast).to eq("Sunny")
      expect(forecast.second.detailed_forecast).to eq("Sunny, with a high near 65.")
    end
  end
end
