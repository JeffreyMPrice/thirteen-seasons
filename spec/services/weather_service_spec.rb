require 'rails_helper'

RSpec.describe WeatherService do
  let(:adapter) { instance_double(WeatherGovAdapter) }
  let(:service) { WeatherService.new(adapter: adapter) }
  let(:latitude) { 37.7749 }
  let(:longitude) { -122.4194 }

  describe "#get_current_weather" do
    it "returns the current weather from the adapter" do
      weather = Weather.new(
        temperature: 46.4,
        dewpoint: 35.6,
        wind_direction: 270,
        wind_speed: 7.56,
        barometric_pressure: 102170,
        visibility: 16090,
        relative_humidity: 65.848771416258,
      )

      allow(adapter).to receive(:current_weather).with(latitude, longitude).and_return(weather)

      result = service.current_weather(latitude, longitude)
      expect(result.temperature).to eq(46.4)
      expect(result.dewpoint).to eq(35.6)
      expect(result.wind_direction).to eq(270)
      expect(result.wind_speed).to eq(7.56)
      expect(result.barometric_pressure).to eq(102170)
      expect(result.visibility).to eq(16090)
      expect(result.relative_humidity).to eq(65.848771416258)
    end

    it "returns nil if the adapter returns nil" do
      allow(adapter).to receive(:current_weather).with(latitude, longitude).and_return(nil)

      result = service.current_weather(latitude, longitude)
      expect(result).to be_nil
    end
  end
end
