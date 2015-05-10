require 'spec_helper'

describe WFlow::ProcessNode do
  describe '.new' do
    context 'when invoked' do
      let(:tasks)   { [:method_name] }
      let(:options) { { if: '', unless: '', around: '' } }
      before { @process_node = WFlow::ProcessNode.new(tasks, options) }

      it 'returns new instance of WFlow::ProcessNode' do
        expect(@process_node).to be_a(WFlow::ProcessNode)
      end
    end
  end

  describe '.execute' do
    let(:process_node) { WFlow::ProcessNode.new(tasks, options) }
    let(:tasks)   { [] }
    let(:options) { {} }
    let(:flow)    { double }
    let(:process) { double(test_method: true, flow: flow) }

    context 'for instance initialized with a method name in tasks (String)' do
      let(:tasks) { ['test_method'] }

      context 'when invoked' do
        it 'invokes method name in tasks, binded at object in argument' do
          expect(process).to receive(:test_method)
          process_node.execute(process)
        end
      end
    end

    context 'for instance initialized with a method name in tasks (Symbol)' do
      let(:tasks) { [:test_method] }

      context 'when invoked' do
        it 'invokes method name in tasks, binded at object in argument' do
          expect(process).to receive(:test_method)
          process_node.execute(process)
        end
      end
    end

    context 'for instance initialized with a Proc in tasks' do
      let(:tasks) { [Proc.new { test_method }] }

      context 'when invoked' do
        it 'invokes Proc in tasks, binded at object in argument' do
          expect(process).to receive(:test_method)
          process_node.execute(process)
        end
      end
    end

    context 'for instance initialized with a WFlow::Process class in tasks' do
      let(:task_process) { WFlow::Process }
      let(:tasks)        { [task_process] }

      context 'when invoked' do
        it 'invokes class instance in tasks, passing flow as argument' do
          expect(task_process).to receive(:run_as_task).with(flow)
          expect(process).to receive(:flow)
          process_node.execute(process)
        end
      end
    end
  end
end