module Tako
  module ActiveRecordExt
    module AssociationRelation
      SHARDED_METHODS = [
        :any?,
        :build,
        :calculate,
        :create,
        :create!,
        :delete,
        :delete_all,
        :destroy,
        :destroy_all,
        :empty?,
        :exists?,
        :include?,
        :length,
        :many?,
        :pluck,
        :select,
        :size,
        :load,
        :uniq,
      ] & ActiveRecord::AssociationRelation.public_instance_methods

      def self.included(mod)
        mod.extend(ShardedMethods)
        mod.sharded_methods *SHARDED_METHODS
      end

      def current_shard
        @association.owner.current_shard
      end
    end
  end
end

ActiveRecord::AssociationRelation.class_eval do
  include Tako::ActiveRecordExt::AssociationRelation
end
