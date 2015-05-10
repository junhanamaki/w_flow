require 'spec_helper'

describe WFlow::Flow do
  describe '.new' do
    context 'when invoked with a non Hash argument' do
      it 'raises WFlow::InvalidArgument error' do
        expect do
          WFlow::Flow.new(Object.new)
        end.to raise_error(WFlow::InvalidArgument)
      end
    end

    context 'when invoked without arguments' do
      before { @flow = WFlow::Flow.new }

      it 'returns a new instance of WFlow::Flow' do
        expect(@flow).to be_a(WFlow::Flow)
      end
    end

    context 'when invoked with an Hash' do
      let(:hash) { { content: 1 } }
      before     { @flow = WFlow::Flow.new(hash) }

      it 'returns a new instance of WFlow::Flow' do
        expect(@flow).to be_a(WFlow::Flow)
      end
    end
  end

  describe '#data' do
    before { @flow = WFlow::Flow.new }

    it 'returns a instance of WFlow::Data' do
      expect(@flow.data).to be_a(WFlow::Data)
    end
  end

  describe '#success?' do
    before { @flow = WFlow::Flow.new }

    context 'if #failure! was not invoked' do
      it 'returns true' do
        expect(@flow.success?).to eq(true)
      end
    end

    context 'after #failure! was invoked' do
      before { @flow.failure! }

      it 'returns false' do
        expect(@flow.success?).to eq(false)
      end
    end
  end

  describe '#failure?' do
    before { @flow = WFlow::Flow.new }

    context 'if #failure! was not invoked' do
      it 'returns false' do
        expect(@flow.failure?).to eq(false)
      end
    end

    context 'if #failure! was invoked' do
      before { @flow.failure! }

      it 'returns true' do
        expect(@flow.failure?).to eq(true)
      end
    end
  end

  describe '#failure!' do
    before { @flow = WFlow::Flow.new }

    context 'when invoked without arguments' do
      before { @flow.failure! }

      it 'sets flow as failure' do
        expect(@flow.failure?).to eq(true)
      end

      it 'does not set failure_message' do
        expect(@flow.failure_message).to be_nil
      end
    end

    context 'when invoked with an argument' do
      let(:args) { { status: 0, message: 'for testing' }}
      before     { @flow.failure!(args) }

      it 'sets flow as failure' do
        expect(@flow.failure?).to eq(true)
      end

      it 'sets passed argument as failure_message' do
        expect(@flow.failure_message).to eq(args)
      end
    end
  end

  describe '#failure_message' do
    before { @flow = WFlow::Flow.new }

    context 'if failure! was not invoked' do
      it 'returns nil' do
        expect(@flow.failure_message).to be_nil
      end
    end

    context 'if failure! was invoked without arguments' do
      before { @flow.failure! }

      it 'returns nil' do
        expect(@flow.failure_message).to be_nil
      end
    end

    context 'if failure! was invoked with an argument' do
      let(:args) { { status: 0 } }
      before     { @flow.failure!(args) }

      it 'returns passed argument' do
        expect(@flow.failure_message).to eq(args)
      end
    end
  end

  describe '#stop!' do
  end

  describe '#skip!' do
  end
end