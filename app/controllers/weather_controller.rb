class WeatherController < ApplicationController
  def index
    @address = weather_params[:address]

    if @address.empty?
      flash.now[:error] = "Address cannot be blank."
    else
      geolocation_service = GeolocationService.new
      @location = geolocation_service.geolocate(@address)
      if @location.valid?
        weather_service = WeatherService.new

        current_weather = weather_service.current_weather(@location)
        @weather_from_cache = current_weather[:from_cache]
        @weather = current_weather[:weather]

        forecast = weather_service.forecast(@location)
        @forecast_from_cache = forecast[:from_cache]
        @forecast = forecast[:forecast]
        flash.now[:notice] = "Weather data successfully retrieved for #{@location.formatted_address}."
      else
        flash.now[:error] = @location.errors.full_messages.to_sentence
      end
    end
  end

  private

  def weather_params
    params.permit(:address)
  end
end
