class WeatherController < ApplicationController
  def index
    @address = weather_params[:address]

    if @address && @address.empty?
        flash.now[:error] = "Address cannot be blank."
    end
  end

  private

  def weather_params
    params.permit(:address)
  end
end
