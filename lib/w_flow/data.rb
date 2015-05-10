module WFlow
  class Data
    def initialize(data = {})
      unless data.is_a?(Hash)
        raise InvalidArgument, 'argument must be of type Hash'
      end

      @data = data
    end

  protected

    def method_missing(method_name, *args, &block)
      method_name = method_name.to_s

      if method_name[-1] == '='
        @data[method_name[0..-2].to_sym] = args[0]
      else
        @data[method_name.to_sym]
      end
    end
  end
end