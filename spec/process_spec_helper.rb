class TestSetup
  include WFlow::Process

  def setup
    flow.data.execution << 'setup'
  end
end