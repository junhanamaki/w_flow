require 'spec_helper'
require 'process_spec_helper'

describe 'class that includes WFlow::Process' do
  describe '.data_reader' do
    context "when invoked with attribute names" do
      let(:mock_class) do
        Class.new do
          include WFlow::Process

          data_reader :book

          def perform
            flow.data.instance = self
            flow.data.flow     = flow
          end
        end
      end
      before { @report = mock_class.run(book: 'book') }

      it "creates a getter with attribute name" do
      end
    end
  end

  describe '.data_writer' do
  end

  describe '.data_accessor' do
  end
end