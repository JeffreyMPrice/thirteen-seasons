require 'rails_helper'

RSpec.describe GoogleMapsAdapter do
  let(:adapter) { GoogleMapsAdapter.new }
  let(:address) { Address.new(plain_text: "123 Main St") }
  let(:client) { double("GoogleMapsService::Client") }

  before do
    allow(GoogleMapsService::Client).to receive(:new).and_return(client)
  end

  describe "#geolocate" do
    it "returns the geolocated address" do
      results = [
        {
          geometry: {
            location: { lat: 37.7749, lng: -122.4194 }
          },
          formatted_address: "123 Main St, San Francisco, CA 94103, USA",
          address_components: [
            { long_name: "123", types: [ "street_number" ] },
            { long_name: "Main St", types: [ "route" ] },
            { long_name: "San Francisco", types: [ "locality" ] },
            { long_name: "CA", types: [ "administrative_area_level_1" ] },
            { long_name: "94103", types: [ "postal_code" ] },
            { long_name: "USA", types: [ "country" ] }
          ]
        }
      ]
      allow(client).to receive(:geocode).with("123 Main St").and_return(results)

      result = adapter.geolocate("123 Main St")
      expect(result.latitude).to eq(37.7749)
      expect(result.longitude).to eq(-122.4194)
      expect(result.formatted_address).to eq("123 Main St, San Francisco, CA 94103, USA")
      expect(result.street_number).to eq("123")
      expect(result.street_name).to eq("Main St")
      expect(result.city).to eq("San Francisco")
      expect(result.state).to eq("CA")
      expect(result.postal_code).to eq("94103")
      expect(result.country).to eq("USA")
    end

    it "returns nil if no results are found" do
      allow(client).to receive(:geocode).with("123 Main St").and_return([])

      result = adapter.geolocate("123 Main St")
      expect(result).to be_nil
    end
  end
end
