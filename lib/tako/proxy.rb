module Tako
  class Proxy
    attr_reader :shard_name
    attr_reader :connection

    def initialize(shard_name, connection)
      @shard_name = shard_name
      @connection = connection
    end

    def in_proxy
      Tako::ProxyStack.in_piles(self) do
        yield
      end
    end
  end
end
