require 'spec_helper'
require 'process_spec_helper'

describe 'class that includes WFlow::Process' do
  describe '.data_reader' do
    context "when invoked with attribute names" do
      before         { @report = DataReaderTest.run(book: 'book') }
      let(:instance) { @report.data.instance }
      let(:flow)     { @report.data.flow }

      it 'creates a method with attribute name' do
        expect(instance).to respond_to(:book)
      end

      it 'created method returns value in flow.data.<attribute name>' do
        binding.pry
        expect(instance.book).to eq(flow.data.book)
      end
    end
  end

  describe '.data_writer' do
  end

  describe '.data_accessor' do
  end
end