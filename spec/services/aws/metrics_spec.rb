require 'rails_helper'

describe Aws::Metrics, type: :service do
  describe '#send_to_cloudwatch' do
    it 'logs metrics to Cloudwatch' do
      allow_any_instance_of(Aws::CloudWatch::Client).to receive(:put_metric_data) { true }

      expect(Aws::Metrics.new(namespace: 'es', aws_metrics: {}).send_to_cloudwatch).to eq(true)
    end
  end
end
