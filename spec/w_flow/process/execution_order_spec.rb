require 'spec_helper'
require 'process_spec_helper'

describe 'class that includes WFlow::Process' do
  let(:params) { { execution_order: [] } }

  describe '.run' do
    context 'when invoked on AProcess' do
      before { @report = AProcess.run(params) }
      let(:execution_order) { @report.data.execution_order }

      it 'returned execution_order has only 3 entries' do
        expect(execution_order.count).to eq(3)
      end

      it 'executes setup first' do
        expect(execution_order[0]).to eq('a_setup')
      end

      it 'executes perform second' do
        expect(execution_order[1]).to eq('a_perform')
      end

      it 'executes finalize last' do
        expect(execution_order[2]).to eq('a_finalize')
      end
    end
  end
end