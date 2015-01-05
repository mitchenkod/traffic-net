require 'rails_helper'

describe Api::VerticesController do

  describe '#index' do
    before do
      create :vertex, x: 1, y: 1
      create :vertex, x: 2, y: 2
    end

    it 'expect vertices' do
      get :index, format: :json
      expect(assigns(:vertices).count).to eq(2)
    end
  end

  describe '#create' do
    it 'expect to create' do
      post :create, vertex: {x: 1, y: 1}
      expect(assigns(:vertex).x).to eq(1)
      expect(assigns(:vertex).y).to eq(1)
    end
  end
end