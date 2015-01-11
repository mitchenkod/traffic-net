require 'rails_helper'

describe Hypernet, type: :model do
  describe '#dijkstra' do
    subject {Hypernet.dijkstra v1, 'val'}

    describe 'first example' do
      let(:v1){create :vertex, val: 0}
      let(:v2){create :vertex, val: 0}
      let(:v3){create :vertex, val: 0}
      before do
        create :edge, outcoming_vertex: v1, incoming_vertex: v2, val: 1
        create :edge, outcoming_vertex: v2, incoming_vertex: v3, val: 1
        create :edge, outcoming_vertex: v1, incoming_vertex: v3, val: 100
      end

      it 'right weights' do
        expect(subject).to include([1, v2.id.to_s])
        expect(subject).to include([2, v3.id.to_s])
      end
    end

    describe 'second example' do
      let(:v1){create :vertex, val: 0}
      let(:v2){create :vertex, val: 0}
      let(:v3){create :vertex, val: 0}
      let(:v4){create :vertex, val: 0}
      let(:v5){create :vertex, val: 0}
      let(:v6){create :vertex, val: 0}
      before do
        create :edge, outcoming_vertex: v1, incoming_vertex: v2, val: 7
        create :edge, outcoming_vertex: v2, incoming_vertex: v1, val: 7
        create :edge, outcoming_vertex: v1, incoming_vertex: v3, val: 9
        create :edge, outcoming_vertex: v3, incoming_vertex: v1, val: 9
        create :edge, outcoming_vertex: v1, incoming_vertex: v6, val: 14
        create :edge, outcoming_vertex: v6, incoming_vertex: v1, val: 14
        create :edge, outcoming_vertex: v2, incoming_vertex: v3, val: 10
        create :edge, outcoming_vertex: v3, incoming_vertex: v2, val: 10
        create :edge, outcoming_vertex: v2, incoming_vertex: v4, val: 15
        create :edge, outcoming_vertex: v4, incoming_vertex: v2, val: 15
        create :edge, outcoming_vertex: v3, incoming_vertex: v4, val: 11
        create :edge, outcoming_vertex: v4, incoming_vertex: v3, val: 11
        create :edge, outcoming_vertex: v3, incoming_vertex: v6, val: 2
        create :edge, outcoming_vertex: v6, incoming_vertex: v3, val: 2
        create :edge, outcoming_vertex: v4, incoming_vertex: v5, val: 6
        create :edge, outcoming_vertex: v5, incoming_vertex: v4, val: 6
        create :edge, outcoming_vertex: v6, incoming_vertex: v5, val: 9
        create :edge, outcoming_vertex: v5, incoming_vertex: v6, val: 9
      end

      it 'right weights' do
        expect(subject).to include([7, v2.id.to_s])
        expect(subject).to include([9, v3.id.to_s])
        expect(subject).to include([20, v4.id.to_s])
        expect(subject).to include([20, v5.id.to_s])
        expect(subject).to include([11, v6.id.to_s])
      end
    end

  end
end