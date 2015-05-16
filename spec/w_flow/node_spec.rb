require 'spec_helper'

describe WFlow::Node do
  describe '.new' do
    context 'when invoked' do
      let(:elements)   { [:method_name] }
      let(:options) { { if: '', unless: '', around: '' } }
      before { @node = WFlow::Node.new(elements, options) }

      it 'returns new instance of WFlow::Node' do
        expect(@node).to be_a(WFlow::Node)
      end
    end
  end

  describe '.execute' do
    let(:node) { WFlow::Node.new(elements, options) }
    let(:elements)   { [] }
    let(:options) { {} }
    let(:flow)    { double }
    let(:process) { double(test_method: true, flow: flow) }

    context 'for instance initialized with a method name in elements (String)' do
      let(:elements) { ['test_method'] }

      context 'when invoked' do
        it 'invokes method name in elements, binded at object in argument' do
          expect(process).to receive(:test_method)
          node.execute(process)
        end
      end
    end

    context 'for instance initialized with a method name in elements (Symbol)' do
      let(:elements) { [:test_method] }

      context 'when invoked' do
        it 'invokes method name in elements, binded at object in argument' do
          expect(process).to receive(:test_method)
          node.execute(process)
        end
      end
    end

    context 'for instance initialized with a Proc in elements' do
      let(:elements) { [Proc.new { test_method }] }

      context 'when invoked' do
        it 'invokes Proc in elements, binded at object in argument' do
          expect(process).to receive(:test_method)
          node.execute(process)
        end
      end
    end

    context 'for instance initialized with a WFlow::Process class in elements' do
      let(:task_process) { WFlow::Process }
      let(:elements)        { [task_process] }

      context 'when invoked' do
        it 'invokes class instance in elements, passing flow as argument' do
          expect(task_process).to receive(:run_as_task).with(flow)
          expect(process).to receive(:flow)
          node.execute(process)
        end
      end
    end
  end
end