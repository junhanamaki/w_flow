class AProcess
  include WFlow::Process

end

class BProcess
  include WFlow::Process

  def setup
  end

  def perform
  end

  def final
  end
end

class CProcess
  include WFlow::Process

  def setup
  end

  execute AProcess

  def perform
  end

  def final
  end
end

class CProcess
end