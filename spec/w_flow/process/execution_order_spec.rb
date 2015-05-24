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

    context 'when invoked on CProcess' do
      let(:test_class) { CProcess }

      it 'reports success' do
        expect(@report.success?).to eq(true)
      end

      it 'returned execution_order has 1 entry' do
        expect(execution_order.count).to eq(1)
      end

      it 'executes finalize first' do
        expect(execution_order[0]).to eq('c_finalize')
      end
    end

    context 'when invoked on DProcess' do
      let(:test_class) { DProcess }

      it 'reports success' do
        expect(@report.success?).to eq(true)
      end

      it 'returned execution_order has 6 entries', :t do
        expect(execution_order.count).to eq(6)
      end

      it 'executes DProcess#setup first' do
        expect(execution_order[0]).to eq('d_setup')
      end

      it 'executes AProcess#setup second' do
        expect(execution_order[1]).to eq('a_setup')
      end

      it 'executes AProcess#perform third' do
        expect(execution_order[2]).to eq('a_perform')
      end

      it 'executes DProcess#perform fourth' do
        expect(execution_order[3]).to eq('d_perform')
      end

      it 'executes AProcess#Finalize fifth' do
        expect(execution_order[4]).to eq('a_finalize')
      end

      it 'executes DProcess#Finalize last' do
        expect(execution_order[5]).to eq('d_finalize')
      end
    end
  end
end