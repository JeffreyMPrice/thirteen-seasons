class WeatherController < ApplicationController
  def index
    @raw_address = weather_params[:raw_address]

    if @raw_address
      if @raw_address.empty?
        flash.now[:error] = "Address cannot be blank."
      else
        geolocation_service = GeolocationService.new
        address = geolocation_service.geolocate(@raw_address)
        flash.now[:notice] = "Geolocation successful: #{address.formatted_address}"
      end
    end
  end

  private

  def weather_params
    params.permit(:raw_address)
  end
end
