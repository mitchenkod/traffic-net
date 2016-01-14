require 'rails_helper'

describe Edge do
  describe '#t_res' do
    subject {edge.t_res}

    shared_examples 'get right time' do
      it 'expect right time' do
        expect(subject).to eq(time)
      end
    end

    describe 'free traffic' do
      let(:time){100}
      let(:edge){create :edge, p_max: 10, p_mid: 5, business: 3, t_0: 100}
      include_examples 'get right time'
    end

    describe 'congested traffic' do
      let(:time){150}
      let(:edge){create :edge, p_max: 10, p_mid: 5, business: 8, t_0: 100}
      include_examples 'get right time'
    end

    describe 'congested traffic#2' do
      let(:time){150}
      let(:edge){create :edge, p_max: 10, p_mid: 5, business: 5, t_0: 100}
      include_examples 'get right time'
    end

    describe 'traffic jam' do
      let(:time){200}
      let(:edge){create :edge, p_max: 10, p_mid: 5, business: 10, t_0: 100}
      include_examples 'get right time'
    end

    describe 'traffic jam#2' do
      let(:time){200}
      let(:edge){create :edge, p_max: 10, p_mid: 5, business: 11, t_0: 100}
      include_examples 'get right time'
    end

  end
end