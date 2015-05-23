require 'spec_helper'

describe 'class that includes WFlow::Process' do
  let(:mock_class) do
    Class.new do
      include WFlow::Process

      data_reader   :reader
      data_writer   :writer
      data_accessor :accessor

      def perform
        flow.data.instance = self
        flow.data.flow     = flow
      end
    end
  end
  before         { @report = mock_class.run(reader: 'reader_val') }
  let(:instance) { @report.data.instance }
  let(:flow)     { @report.data.flow }

  describe '.data_reader' do
    context "when invoked" do
      it 'creates getter methods with passed attribute names' do
        expect(instance).to respond_to(:reader)
      end

      it 'created method returns value in flow.data.<attribute name>' do
        expect(instance.reader).to eq(flow.data.reader)
      end
    end
  end

  describe '.data_writer' do
    context 'when invoked' do
      let(:writer_val) { 'writer_val' }
      before           { instance.writer = writer_val }

      it 'creates setter methods with passed attribute names' do
        expect(instance).to respond_to('writer=')
      end

      it 'created method sets value in flow.data.<attribute name>' do
        expect(flow.data.writer).to eq(writer_val)
      end
    end
  end

  describe '.data_accessor' do
    context 'when invoked' do
      let(:accessor_val) { 'new_accessor_val' }
      before { instance.accessor = accessor_val }

      it 'creates getter methods with passed attribute names' do
        expect(instance).to respond_to(:accessor)
      end

      it 'creates setter methods with passed attribute names' do
        expect(instance).to respond_to("accessor=")
      end

      it 'created getter method returns value in flow.data.<attribute name>' do
        expect(instance.accessor).to eq(flow.data.accessor)
      end

      it 'created setter method sets value in flow.data.<attribute name>' do
        expect(flow.data.accessor).to eq(accessor_val)
      end
    end
  end
end