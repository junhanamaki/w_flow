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

      it 'returned execution_order has 6 entries' do
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

    context 'when invoked on EProcess' do
      let(:test_class) { EProcess }

      it 'reports success' do
        expect(@report.success?).to eq(true)
      end

      it 'returned execution_order has 6 entries' do
        expect(execution_order.count).to eq(6)
      end

      it 'executes EProcess#setup first' do
        expect(execution_order[0]).to eq('e_setup')
      end

      it 'executes AProcess#setup second' do
        expect(execution_order[1]).to eq('a_setup')
      end

      it 'executes AProcess#perform third' do
        expect(execution_order[2]).to eq('a_perform')
      end

      it 'executes EProcess#perform fourth' do
        expect(execution_order[3]).to eq('e_perform')
      end

      it 'executes AProcess#Finalize fifth' do
        expect(execution_order[4]).to eq('a_finalize')
      end

      it 'executes EProcess#Finalize last' do
        expect(execution_order[5]).to eq('e_finalize')
      end
    end

    context 'when invoked on FProcess' do
      let(:test_class) { FProcess }

      it 'reports success' do
        expect(@report.success?).to eq(true)
      end

      it 'returned execution_order has 3 entries' do
        expect(execution_order.count).to eq(3)
      end

      it 'executes FProcess#setup first' do
        expect(execution_order[0]).to eq('f_setup')
      end

      it 'executes FProcess#perform second' do
        expect(execution_order[1]).to eq('f_perform')
      end

      it 'executes FProcess#finalize third' do
        expect(execution_order[2]).to eq('f_finalize')
      end
    end

    context 'when invoked on GProcess' do
      let(:test_class) { GProcess }

      it 'reports success' do
        expect(@report.success?).to eq(true)
      end

      it 'returned execution_order has 1 entries' do
        expect(execution_order.count).to eq(1)
      end

      it 'executes GProcess#finalize first' do
        expect(execution_order[0]).to eq('g_finalize')
      end
    end

    context 'when invoked on HProcess' do
      let(:test_class) { HProcess }

      it 'reports success' do
        expect(@report.success?).to eq(true)
      end

      it 'returned execution_order has 5 entries' do
        expect(execution_order.count).to eq(5)
      end

      it 'executes HProcess#setup first' do
        expect(execution_order[0]).to eq('h_setup')
      end

      it 'executes BProcess#setup second' do
        expect(execution_order[1]).to eq('b_setup')
      end

      it 'executes HProcess#perform third' do
        expect(execution_order[2]).to eq('h_perform')
      end

      it 'executes BProcess#finalize fourth' do
        expect(execution_order[3]).to eq('b_finalize')
      end

      it 'executes HProcess#finalize fifth' do
        expect(execution_order[4]).to eq('h_finalize')
      end
    end

    context 'when invoked on IProcess' do
      let(:test_class) { IProcess }

      it 'reports success' do
        expect(@report.success?).to eq(true)
      end

      it 'returned execution_order has 4 entries' do
        expect(execution_order.count).to eq(4)
      end

      it 'executes IProcess#setup first' do
        expect(execution_order[0]).to eq('i_setup')
      end

      it 'executes IProcess#perform second' do
        expect(execution_order[1]).to eq('i_perform')
      end

      it 'executes GProcess#finalize third' do
        expect(execution_order[2]).to eq('g_finalize')
      end

      it 'executes IProcess#finalize fourth' do
        expect(execution_order[3]).to eq('i_finalize')
      end
    end

    context 'when invoked on JProcess' do
      let(:test_class) { JProcess }

      it 'reports success' do
        expect(@report.success?).to eq(true)
      end

      it 'returned execution_order has 9 entries' do
        expect(execution_order.count).to eq(9)
      end

      it 'executes JProcess#setup first' do
        expect(execution_order[0]).to eq('j_setup')
      end

      it 'executes AProcess#setup second' do
        expect(execution_order[1]).to eq('a_setup')
      end

      it 'executes AProcess#perform third' do
        expect(execution_order[2]).to eq('a_perform')
      end

      it 'executes AProcess#setup fourth' do
        expect(execution_order[3]).to eq('a_setup')
      end

      it 'executes AProcess#perform fifth' do
        expect(execution_order[4]).to eq('a_perform')
      end

      it 'executes JProcess#perform sixth' do
        expect(execution_order[5]).to eq('j_perform')
      end

      it 'executes AProcess#finalize seventh' do
        expect(execution_order[6]).to eq('a_finalize')
      end

      it 'executes AProcess#finalize eight' do
        expect(execution_order[7]).to eq('a_finalize')
      end

      it 'executes JProcess#finalize ninth' do
        expect(execution_order[8]).to eq('j_finalize')
      end
    end
  end
end