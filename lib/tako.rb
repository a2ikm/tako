require 'erb'
require "tako/version"
require "tako/config"
require "tako/active_record_ext"
require "tako/repository"
require "tako/proxy_stack"
require "tako/proxy"
require "tako/query_chain"
require "tako/multi_shard_execution"

module Tako
  extend MultiShardExecution

  class << self
    def shard(shard_name)
      if block_given?
        Tako::Repository.shard(shard_name).in_proxy do
          yield
        end
      else
        raise "gimme a block!"
      end
    end

    def load_connections_from_yaml
      (config[env] || []).each do |shard_name, conf|
        Tako::Repository.add(shard_name, conf)
      end
    end

    def config
      Tako::Config.shards_yml[:tako]
    end

    def env
      Tako::Config.env
    end
  end
end

require 'active_record'

ActiveRecord::ConnectionHandling.class_eval do
  prepend Tako::ActiveRecordExt::ConnectionHandling::Overrides
end

ActiveRecord::Base.class_eval do
  extend Tako::ActiveRecordExt::Base::ClassMethods
  include Tako::ActiveRecordExt::Base::InstanceMethods
  include Tako::ActiveRecordExt::Base::Overrides
end

ActiveRecord::Associations::Association.class_eval do
  include Tako::ActiveRecordExt::Association::Overrides
end

ActiveRecord::Associations::CollectionAssociation.class_eval do
  include Tako::ActiveRecordExt::CollectionAssociation::Overrides
end

ActiveRecord::Associations::SingularAssociation.class_eval do
  include Tako::ActiveRecordExt::SingularAssociation::Overrides
end

ActiveRecord::Associations::CollectionProxy.class_eval do
  include Tako::ActiveRecordExt::CollectionProxy::Overrides
end

ActiveRecord::AssociationRelation.class_eval do
  include Tako::ActiveRecordExt::AssociationRelation::Overrides
end

ActiveRecord::LogSubscriber.class_eval do
  prepend Tako::ActiveRecordExt::LogSubscriber::Overrides
end

require 'tako/railtie' if defined?(::Rails)
