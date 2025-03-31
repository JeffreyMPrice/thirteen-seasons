require 'rails_helper'

RSpec.describe WeatherService do
  let(:adapter) { instance_double(WeatherGovAdapter) }
  let(:service) { WeatherService.new(adapter: adapter) }
  let(:location) do
    Location.new(
      address: "123 Main St",
      latitude: 37.7749,
      longitude: -122.4194,
      formatted_address: "123 Main St, San Francisco, CA 94103, USA",
      postal_code: "94103"
    )
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
  let(:expected_forecast) { [ Forecast.new(name: "Tonight", temperature: 50) ] }

  describe "#current_weather" do
    it "returns the current weather from the adapter" do
      allow(adapter).to receive(:current_weather).with(location.latitude, location.longitude).and_return(expected_weather)

      result = service.current_weather(location)
      weather = result[:weather]

      expect(weather.temperature).to eq(46.4)
      expect(weather.dewpoint).to eq(35.6)
      expect(weather.wind_direction).to eq(270)
      expect(weather.wind_speed).to eq(7.56)
      expect(weather.barometric_pressure).to eq(102170)
      expect(weather.visibility).to eq(16090)
      expect(weather.relative_humidity).to eq(65.848771416258)
    end

    it "returns nil if the adapter returns nil" do
      allow(adapter).to receive(:current_weather).with(location.latitude, location.longitude).and_return(nil)

      result = service.current_weather(location)
      weather = result[:weather]

      expect(weather).to be_nil
    end

    context "when WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES is not set" do
      around do |example|
        original_timeout = ENV["WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES"]
        ENV["WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES"] = nil
        example.run
        ENV["WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES"] = original_timeout
      end

      it "expires the current_weather cache after 30 minutes" do
        allow(adapter).to receive(:current_weather).and_return(expected_weather)

        # First call should fetch from the adapter
        service.current_weather(location)
        expect(adapter).to have_received(:current_weather).once

        # Advance time by 31 minutes
        Timecop.travel(31.minutes.from_now) do
          # Second call should fetch from the adapter again
          service.current_weather(location)
          expect(adapter).to have_received(:current_weather).twice
        end
      end
    end
    context "when WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES is set" do
      it "expires the current_weather cache after 15 minutes" do
        allow(service).to receive(:current_weather_cache_timeout).and_return(15.minutes)
        allow(adapter).to receive(:current_weather).and_return(expected_weather)

        # First call should fetch from the adapter
        service.current_weather(location)
        expect(adapter).to have_received(:current_weather).once

        # Advance time by 16 minutes
        Timecop.travel(16.minutes.from_now) do
          # Second call should fetch from the adapter again
          service.current_weather(location)
          expect(adapter).to have_received(:current_weather).twice
        end
        # Advance time by another minute - cache should not be expired
        Timecop.travel(1.minute.from_now) do
          # Second call should fetch from the adapter again
          service.current_weather(location)
          expect(adapter).to have_received(:current_weather).twice
        end
      end
    end
  end

  describe "#forecast" do
    context "when WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES is not set" do
      around do |example|
        original_timeout = ENV["WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES"]
        ENV["WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES"] = nil
        example.run
        ENV["WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES"] = original_timeout
      end

      it "expires the forecast cache after 30 minutes" do
        allow(adapter).to receive(:forecast).and_return(expected_forecast)
        cache_time = service.send(:current_weather_cache_timeout)
        expect(cache_time).to eq(30.minutes)

        # First call should fetch from the adapter
        results = service.forecast(location)
        expect(results[:from_cache]).to be_falsey
        expect(adapter).to have_received(:forecast).once

        # Advance time by 29 minutes
        Timecop.travel(29.minutes)

        # Second call should fetch from the adapter again
        results = service.forecast(location)
        expect(results[:from_cache]).to be_truthy
        expect(adapter).to have_received(:forecast).once

        # Advance time by 1 minutes
        Timecop.travel(1.minutes)
        results = service.forecast(location)
        expect(results[:from_cache]).to be_falsey
        expect(adapter).to have_received(:forecast).twice
      end
    end
  end

  context "when WEATHER_SERVICE_CACHE_TIMEOUT_MINUTES is set" do
    it "expires the forecast cache after 15 minutes" do
      allow(service).to receive(:current_weather_cache_timeout).and_return(15.minutes)
      allow(adapter).to receive(:forecast).and_return(expected_forecast)

      # First call should fetch from the adapter
      results = service.forecast(location)
      expect(results[:from_cache]).to be_falsey
      expect(adapter).to have_received(:forecast).once

      # Advance time by 14 minutes
      Timecop.travel(14.minutes.from_now)
      # Second call should fetch from the adapter again
      results = service.forecast(location)
      expect(results[:from_cache]).to be_truthy
      expect(adapter).to have_received(:forecast).once

      # Advance time by 2 minutes
      Timecop.travel(2.minutes.from_now)
      # Second call should fetch from the adapter again
      results = service.forecast(location)
      expect(results[:from_cache]).to be_falsey
      expect(adapter).to have_received(:forecast).twice
    end
  end
end
