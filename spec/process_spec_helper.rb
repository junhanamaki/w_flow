class DataReaderTest
  include WFlow::Process

  data_reader :book

  def perform
    flow.data.instance = self
    flow.data.flow     = flow
  end
end

class DataWriterTest
  include WFlow::Process

  data_writer :book

  def perform
    self.book = 'book'
  end
end

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