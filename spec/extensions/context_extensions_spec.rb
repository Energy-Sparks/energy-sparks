require_relative '../support/context_extensions'
require 'flipper'

RSpec.describe ContextExtensions do
  context 'with feature' do
    context 'with feature', with_feature: :test_feature do
      it { expect(Flipper.enabled?(:test_feature)).to be(true) }
    end

    context with_feature: :test_feature do
      it { expect(Flipper.enabled?(:test_feature)).to be(true) }
    end
  end

  context 'without feature' do
    context 'without feature', without_feature: :test_feature do
      it { expect(Flipper.enabled?(:test_feature)).to be(false) }
    end

    context without_feature: :test_feature do
      it { expect(Flipper.enabled?(:test_feature)).to be(false) }
    end
  end

  context 'when toggling feature - difficult to test' do
    before do
      Flipper.remove(:test_feature)
    end

    context 'when using toggle feature', toggle_feature: :test_feature do
      it 'uses flag' do
        expect(Flipper.exist?(:test_feature)).to be(true)
      end
    end

    context toggle_feature: :test_feature do
      it 'uses flag' do
        expect(Flipper.exist?(:test_feature)).to be(true)
      end
    end
  end

  context 'without extension' do
    before do
      Flipper.remove(:test_feature)
    end

    context 'when not using any context extension' do
      it { expect(Flipper.enabled?(:test_feature)).to be(false) }
      it { expect(Flipper.exist?(:test_feature)).to be(false) }
    end
  end
end
