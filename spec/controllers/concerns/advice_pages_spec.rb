require 'rails_helper'

describe AdvicePages, type: :controller do
  before do
    class TestAdvicePagesController < ApplicationController
      include AdvicePages
    end
  end

  after do
    Object.send :remove_const, :TestAdvicePagesController
  end

  let(:subject) { TestAdvicePagesController.new }

  describe '.variation_rating' do
    it 'shows 0% as 10.0' do
      expect(subject.variation_rating(0)).to eq(10.0)
    end
    it 'shows 10% as 8.0' do
      expect(subject.variation_rating(0.1)).to eq(8.0)
    end
    it 'shows 40% as low 2.0' do
      expect(subject.variation_rating(0.4)).to eq(2.0)
    end
    it 'shows 50% as 0.0' do
      expect(subject.variation_rating(0.5)).to eq(0.0)
    end
  end
end
