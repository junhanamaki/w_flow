require 'spec_helper'

describe WFlow::Data do
  describe '.new' do
    context 'when invoked with an Hash' do
      let(:hash) { { content: 1 } }
      before { @data = WFlow::Data.new(hash) }

      it 'returns a new instance of WFlow::Data' do
        expect(@data).to be_a(WFlow::Data)
      end

      it 'dynamically creates getters for hash, which when invoked returns ' \
         'the value stored in hash' do
        expect(@data.content).to eq(1)
      end

      it 'dynamically creates setters for hash, which when invoked returns ' \
         'sets the value in hash' do
        @data.new_content = 2

        expect(@data.new_content).to eq(2)
      end
    end
  end
end