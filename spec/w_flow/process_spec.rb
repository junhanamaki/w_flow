require 'spec_helper'
require 'process_spec_helper'

describe WFlow::Process, :t do
  describe 'for classes with this module included' do
    describe 'class instance' do

    end

    describe '.run' do
      context 'if class has a setup method defined' do
        let(:params) { { execution: [] } }
        before       { TestSetup.run(params) }

        it 'executes method' do
          expect(params[:execution]).to include('setup')
        end
      end
    end
  end
end