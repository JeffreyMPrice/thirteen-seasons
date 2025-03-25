require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe "GET #index" do
    context "with address parameter" do
      it "assigns @raw_address" do
        allow_any_instance_of(GeolocationService).to receive(:geolocate).and_return(
          Address.new(
            plain_text: "123 Main St",
            latitude: 37.7749,
            longitude: -122.4194,
            formatted_address: "123 Main St, San Francisco, CA 94103, USA"
          )
        )

        get :index, params: { raw_address: "123 Main St" }
        expect(assigns(:raw_address)).to eq("123 Main St")
      end
    end

    context "without address parameter" do
      it "assigns @raw_address as nil" do
        get :index
        expect(assigns(:raw_address)).to be_nil
      end
    end

    context "with blank address parameter" do
      it "sets a flash error message" do
        get :index, params: { raw_address: "" }
        expect(flash.now[:error]).to eq("Address cannot be blank.")
      end
    end

    context "with valid address parameter" do
      it "sets a flash notice message with geolocation results" do
        allow_any_instance_of(GeolocationService).to receive(:geolocate).and_return(
          Address.new(
            plain_text: "123 Main St",
            latitude: 37.7749,
            longitude: -122.4194,
            formatted_address: "123 Main St, San Francisco, CA 94103, USA"
          )
        )

        get :index, params: { raw_address: "123 Main St" }
        expect(flash.now[:notice]).to eq("Geolocation successful: 123 Main St, San Francisco, CA 94103, USA")
      end
    end
  end
end
