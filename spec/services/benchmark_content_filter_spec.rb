require 'rails_helper'

describe BenchmarkContentFilter, type: :service do
  let(:content) do
    [
      { type: :title, content: 'Benchmark name' },
      { type: :html, content: 'intro html' },
      { type: :chart, content: { title: 'chart 1', config_name: 'config_name', x_axis: ['a school'] } },
      { type: :html, content: 'chart html' },
      { type: :table_composite, content: { header: ['table composite header'], rows: [[]] } },

      ## second benchmark
      { type: :title, content: 'Benchmark 2 name' },
      { type: :html, content: 'Benchmark 2 intro' },
      { type: :chart, content: { title: 'chart 2 title', config_name: 'config_name', x_axis: ['a school'] } },

      { type: :html, content: 'table 2 html' },
      { type: :html, content: 'table 2 more html' },
      { type: :table_composite, content: { header: ['table 2 composite header'], rows: [[]] } },
      { type: :html, content: 'table 2 even more html' },
    ]
  end

  subject(:filter) { BenchmarkContentFilter.new(content) }

  describe 'multi?' do
    it { expect(filter.multi?).to be(true) }
  end

  describe 'tables?' do
    it { expect(filter.tables?).to be(true) }
    it { expect(filter.tables?(count: 2)).to be(true) }
  end

  describe 'charts?' do
    it { expect(filter.charts?).to be(true) }
    it { expect(filter.charts?(count: 2)).to be(true) }
  end

  describe '#intro' do
    subject(:intro) { filter.intro }

    it { expect(intro.count).to be(1)}
    it { expect(intro[0][:content]).to eq('intro html')}
  end

  describe '#table' do
    subject(:tables) { filter.tables }

    it { expect(tables.count).to be(7)}
    it { expect(tables[0][:content][:header]).to eq(['table composite header'])}
    it { expect(tables[1][:content]).to eq('Benchmark 2 name')}
    it { expect(tables[2][:content]).to eq('Benchmark 2 intro')}
    it { expect(tables[3][:content]).to eq('table 2 html')}
    it { expect(tables[4][:content]).to eq('table 2 more html')}
    it { expect(tables[5][:content][:header]).to eq(['table 2 composite header'])}
    it { expect(tables[6][:content]).to eq('table 2 even more html')}
  end

  describe '#chart' do
    subject(:charts) { filter.charts }

    it { expect(charts.count).to be(5)}
    it { expect(charts[0][:content][:title]).to eq('chart 1')}
    it { expect(charts[1][:content]).to eq('chart html')}
    it { expect(charts[2][:content]).to eq('Benchmark 2 name')}
    it { expect(charts[3][:content]).to eq('Benchmark 2 intro')}
    it { expect(charts[4][:content][:title]).to eq('chart 2 title')}
  end
end
