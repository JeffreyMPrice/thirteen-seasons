require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  let(:address) { "123 Main St" }
  let(:geolocated_address) do
    Location.new(
      address: address,
      latitude: 37.7749,
      longitude: -122.4194,
      country: 'United States',
      formatted_address: "#{address}, San Francisco, CA 94103, USA"
    )
  end
  let(:weather_data) do
    { weather: Weather.new(
                  temperature: 46.4,
                  dewpoint: 35.6,
                  wind_direction: 270,
                  wind_speed: 7.56,
                  barometric_pressure: 102170,
                  visibility: 16090,
                  relative_humidity: 65.848771416258),
      from_cache: false }
  end
  let(:forecast_data) do
    { forecast: [
      Forecast.new(
        name: "Tonight",
        start_time: "2023-10-27T18:00:00-07:00",
        end_time: "2023-10-28T06:00:00-07:00",
        is_daytime: false,
        temperature: 50,
        temperature_unit: "F",
        short_forecast: "Mostly Clear",
        detailed_forecast: "Mostly clear, with a low around 50."
      ),
      Forecast.new(
        name: "Saturday",
        start_time: "2023-10-28T06:00:00-07:00",
        end_time: "2023-10-28T18:00:00-07:00",
        is_daytime: true,
        temperature: 65,
        temperature_unit: "F",
        short_forecast: "Sunny",
        detailed_forecast: "Sunny, with a high near 65."
      )
    ],
    from_cache: false }
  end
  let(:weather_service) { instance_double(WeatherService) }
  let(:geolocation_service) { instance_double(GeolocationService) }

  before do
    allow(WeatherService).to receive(:new).and_return(weather_service)
    allow(GeolocationService).to receive(:new).and_return(geolocation_service)
    allow(geolocation_service).to receive(:geolocate).and_return(geolocated_address)
    allow(weather_service).to receive(:current_weather).with(geolocated_address).and_return(weather_data)
    allow(weather_service).to receive(:forecast).with(geolocated_address).and_return(forecast_data)
  end

  describe "GET #index" do
    context "with address parameter" do
      it "sets a flash notice message with success and weather results" do
        get :index, params: { address: "123 Main St" }

        expect(flash.now[:notice]).to eq("Weather data successfully retrieved for 123 Main St, San Francisco, CA 94103, USA.")
        expect(assigns(:weather).temperature).to eq(46.4)
        expect(assigns(:weather).dewpoint).to eq(35.6)
        expect(assigns(:weather).wind_direction).to eq(270)
        expect(assigns(:weather).wind_speed).to eq(7.56)
        expect(assigns(:weather).barometric_pressure).to eq(102170)
        expect(assigns(:weather).visibility).to eq(16090)
        expect(assigns(:weather).relative_humidity).to eq(65.848771416258)
        expect(assigns(:forecast)).to eq(forecast_data[:forecast])
      end
    end

    context "without address parameter" do
      it "assigns @address as nil" do
        get :index

        expect(assigns(:address)).to be_nil
      end
    end

    context "with blank address parameter" do
      it "sets a flash error message" do
        get :index, params: { address: "" }

        expect(flash.now[:error]).to eq("Address cannot be blank.")
      end
    end

    context "with valid address parameter" do
      it "sets a flash notice message with seuccess" do
        get :index, params: { address: "123 Main St" }

        expect(flash.now[:notice]).to eq("Weather data successfully retrieved for 123 Main St, San Francisco, CA 94103, USA.")
      end
    end
  end
end
