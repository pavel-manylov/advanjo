#coding: utf-8

#Advanjo gives you freedom to create complex joins in ActiveRecord using power of Arel in beautiful way.
#
#Some good examples can be found in README.MD file
module Advanjo
  class SubQuery
    #@param   ar_object [ActiveRecord::Relation]
    def initialize(ar_object)
      @sub_query=ar_object.build_arel.as(self.class.next_alias!(ar_object.table_name))
    end

    #redirect all unknown queries to Arel::Nodes::TableAlias
    def method_missing(method, *args, &block)
      arel_table_alias.send(method, *args, &block)
    end

    def arel_table_alias
      @sub_query
    end

    class <<self
      def next_alias_id!(table_name)
        table_name = table_name.to_sym
        @aliases = {} unless defined?(@aliases)
        if @aliases[table_name].nil?
          @aliases[table_name]=1
        else
          @aliases[table_name]+=1
        end
        @aliases[table_name]
      end

      def next_alias!(table_name)
        "#{table_name}_sq_#{next_alias_id!(table_name)}"
      end
    end
  end
end

class ActiveRecord::Base
  class <<self
    delegate :advanjo, :outer_advanjo, :to => :scoped
  end
end

class ActiveRecord::Relation
  #Add join to your ActiveRecord::Relation object using arel notation
  #
  #@param   right [ActiveRecord::Relation, ActiveRecord::Base, Arel::Table, Arel::Nodes::TableAlias, Symbol]
  #@return  ActiveRecord::Relation
  def advanjo(right, join_type=:inner,&block)
    right = right.arel_table if right.class==Class && right.ancestors.include?(ActiveRecord::Base)
    right = right.as_sub_query if right.kind_of?(ActiveRecord::Relation)

    puts right.class
    right=case right.class.to_s
           when "Advanjo::SubQuery"
             right.arel_table_alias
           when "Arel::Table" || "Arel::Nodes::TableAlias"
             right
           when "Symbol"
             Arel::Table.new(right)
           else
             raise "Unsupported right join part passed"
          end
    join_class = (join_type == :outer) ? Arel::Nodes::OuterJoin : Arel::Nodes::InnerJoin
    joins(arel_table.join(right, join_class).on(yield(arel_table, right)).join_sources.first)
  end

  #LEFT OUTER JOIN
  def outer_advanjo(right, &block)
    advanjo(right, :outer, &block)
  end

  def as_advanjo_sub_query
    Advanjo::SubQuery.new(self)
  end
end