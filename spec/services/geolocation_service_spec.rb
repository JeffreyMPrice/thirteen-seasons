require 'rails_helper'

RSpec.describe GeolocationService do
  let(:address) { "123 Main St" }
  let(:adapter) { double("GoogleMapsAdapter") }
  let(:service) { GeolocationService.new(adapter: adapter) }

  describe "#geolocate" do
    it "calls the adapter's geolocate method" do
      expect(adapter).to receive(:geolocate).with(address)
      service.geolocate(address)
    end

    it "returns the geolocated address" do
      geolocated_address = Location.new(
        address: "123 Main St",
        latitude: 37.7749,
        longitude: -122.4194,
        country: 'United States',
        formatted_address: "123 Main St, San Francisco, CA 94103, USA"
      )
      allow(adapter).to receive(:geolocate).and_return(geolocated_address)

      result = service.geolocate(address)
      expect(result).to be_a(Location)
      expect(result).to eq(geolocated_address)
    end
  end
end
