require 'spec_helper'
require 'process_spec_helper'

describe 'class that includes WFlow::Process' do
  let(:params)          { { execution_order: [] } }
  let(:execution_order) { @report.data.execution_order }
  before                { @report = test_class.run(params) }

  describe '.run' do
    context 'when invoked on AProcess' do
      let(:test_class) { AProcess }

      it 'reports success' do
        expect(@report.success?).to eq(true)
      end

      it 'returned execution_order has 3 entries' do
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

    context 'when invoked on BProcess' do
      let(:test_class) { BProcess }

      it 'reports failure' do
        expect(@report.success?).to eq(false)
      end

      it 'returned execution_order has 3 entries' do
        expect(execution_order.count).to eq(3)
      end

      it 'executes setup first' do
        expect(execution_order[0]).to eq('b_setup')
      end

      it 'executes rollback second' do
        expect(execution_order[1]).to eq('b_rollback')
      end

      it 'executes finalize last' do
        expect(execution_order[2]).to eq('b_finalize')
      end
    end
  end
end