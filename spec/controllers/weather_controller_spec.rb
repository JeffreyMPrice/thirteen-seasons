require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe "GET #index" do
    context "with address parameter" do
      it "assigns @address" do
        get :index, params: { address: "123 Main St" }
        expect(assigns(:address)).to eq("123 Main St")
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
  end
end
