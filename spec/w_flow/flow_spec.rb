require 'spec_helper'

describe WFlow::Flow do
  let(:hash) { { content: 1 } }
  before     { @flow = WFlow::Flow.new(hash) }

  describe '.new' do
    context 'when invoked with an Hash' do
      it 'returns a new instance of WFlow::Flow' do
        expect(@flow).to be_a(WFlow::Flow)
      end
    end
  end

  describe '#data' do
    it 'returns a instance of WFlow::Data' do
      expect(@flow.data).to be_a(WFlow::Data)
    end
  end

  describe '#success?' do
    context 'if #failure! was not invoked' do
      it 'returns true' do
        expect(@flow.success?).to eq(true)
      end
    end

    context 'after #failure! was invoked' do
      before { @flow.failure! rescue nil }

      it 'returns false' do
        expect(@flow.success?).to eq(false)
      end
    end
  end

  describe '#failure?' do
    context 'if #failure! was not invoked' do
      it 'returns false' do
        expect(@flow.failure?).to eq(false)
      end
    end

    context 'if #failure! was invoked' do
      before { @flow.failure! rescue nil }

      it 'returns true' do
        expect(@flow.failure?).to eq(true)
      end
    end
  end

  describe '#failure!' do
    context 'when invoked without arguments' do
      before { @flow.failure! rescue nil }

      it 'sets flow as failure' do
        expect(@flow.failure?).to eq(true)
      end

      it 'does not set failure_message' do
        expect(@flow.failure_message).to be_nil
      end

      it 'raises WFlow::FlowFailure error' do
        expect do
          @flow.failure!
        end.to raise_error(WFlow::FlowFailure)
      end
    end

    context 'when invoked with an argument' do
      let(:args) { { status: 0, message: 'for testing' }}
      before     { @flow.failure!(args) rescue nil }

      it 'sets flow as failure' do
        expect(@flow.failure?).to eq(true)
      end

      it 'sets passed argument as failure_message' do
        expect(@flow.failure_message).to eq(args)
      end

      it 'raises WFlow::FlowFailure error' do
        expect do
          @flow.failure!
        end.to raise_error(WFlow::FlowFailure)
      end
    end

    context 'when invoked with options[:silent] equal true' do
      let(:options) { { silent: true } }
      before        { @flow.failure!(nil, options) }

      it 'sets flow as failure' do
        expect(@flow.failure?).to eq(true)
      end

      it 'does not set failure_message' do
        expect(@flow.failure_message).to be_nil
      end

      it 'does not raise WFlow::FlowFailure error' do
        expect do
          @flow.failure!(nil, options)
        end.not_to raise_error
      end
    end
  end

  describe '#failure_message' do
    context 'if failure! was not invoked' do
      it 'returns nil' do
        expect(@flow.failure_message).to be_nil
      end
    end

    context 'if failure! was invoked without arguments' do
      before { @flow.failure! rescue nil }

      it 'returns nil' do
        expect(@flow.failure_message).to be_nil
      end
    end

    context 'if failure! was invoked with message' do
      let(:message) { { status: 0 } }
      before        { @flow.failure!(message) rescue nil }

      it 'returns passed message' do
        expect(@flow.failure_message).to eq(message)
      end
    end
  end

  describe '#stop!' do
  end

  describe '#skip!' do
  end
end