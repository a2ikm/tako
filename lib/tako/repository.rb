module Tako
  class Repository
    class << self
      def proxy_configs
        @proxy_configs ||= {}
      end

      def proxy_connections
        @proxy_connections ||= {}
      end

      def clear
        proxy_connections.each do |shard_name, connection|
          connection.disconnect!
          remove_const("TAKO_AR_CLASS_#{shard_name.upcase}")
        end
        proxy_configs.clear
        proxy_connections.clear
      end

      def add(shard_name, conf)
        shard_name = shard_name.to_sym
        return if proxy_configs[shard_name]

        temporary_class = Class.new(ActiveRecord::Base)
        const_set("TAKO_AR_CLASS_#{shard_name.upcase}", temporary_class)
        temporary_class.establish_connection(conf)

        proxy_connections[shard_name] = temporary_class.connection
        proxy_configs[shard_name] = conf
      end

      def create_proxy(shard_name)
        Proxy.new(shard_name, proxy_connections[shard_name.to_sym])
      end

      def shard_names
        proxy_configs.keys
      end
    end
  end
end
