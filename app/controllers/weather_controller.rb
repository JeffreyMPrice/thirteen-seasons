class WeatherController < ApplicationController
  def index
    @raw_address = weather_params[:raw_address]

    if @raw_address
      if @raw_address.empty?
        flash.now[:error] = "Address cannot be blank."
      else
        geolocation_service = GeolocationService.new
        address = geolocation_service.geolocate(@raw_address)
        if address
          weather_service = WeatherService.new
          @weather = weather_service.current_weather(address.latitude, address.longitude)
          flash.now[:notice] = "Geolocation successful: #{address.formatted_address}"
        else
          flash.now[:error] = "Geolocation failed."
        end
      end
    end
  end

  private

  def weather_params
    params.permit(:raw_address)
  end
end
