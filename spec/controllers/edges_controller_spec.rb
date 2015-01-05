require 'rails_helper'

describe Api::EdgesController do

  describe '#index' do
    before do
      vert_one = create :vertex, x: 1, y: 1
      vert_two = create :vertex, x: 0, y: 1
      vert_three = create :vertex, x: 0, y: 0
      create :edge, incoming_vertex: vert_one, outcoming_vertex: vert_two
      create :edge, incoming_vertex: vert_two, outcoming_vertex: vert_three
    end
    it 'expect edges' do
      get :index, format: :json
      expect(assigns(:edges).count).to eq(2)
    end
  end

  describe '#create' do
    let(:vert_one){create :vertex, x: 1, y: 1}
    let(:vert_two){create :vertex, x: 0, y: 1}
    it 'expect to create' do
      post :create, edge: {outcoming_vertex_id: vert_two.id.to_s, incoming_vertex_id: vert_one.id.to_s}, format: :json
      expect(assigns(:edge).incoming_vertex).to eq(vert_one)
      expect(assigns(:edge).outcoming_vertex).to eq(vert_two)
    end
  end
end