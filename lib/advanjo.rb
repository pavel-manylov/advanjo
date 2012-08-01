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
        #TODO change to uniq alias in query, not in all queries
        table_name = table_name.to_sym
        @aliases = {} unless defined?(@aliases)
        if @aliases[table_name].nil?
          @aliases[table_name]=0
        else
          @aliases[table_name]+=1
        end
      end

      def next_alias!(table_name)
        "#{table_name}_sq_#{next_alias_id!(table_name).to_s(36)}"
      end
    end
  end
end

class ActiveRecord::Base
  class <<self
    delegate :construct_advanjo, :advanjo, :outer_advanjo, :to => :scoped
  end
end

class ActiveRecord::Relation
  #Construct join using arel notation
  #
  #@param   right       [ActiveRecord::Relation, ActiveRecord::Base, Arel::Table, Arel::Nodes::TableAlias, Symbol]
  #@param   join_type   [Symbol]  :inner or :outer
  #@param   alias_name  [String, Symbol]  set alias_name as alias for joined table
  #@block   join on condition in arel notation. Variables passed to block are Arel::Nodes::TableAlias or Arel::Table.
  #         first variable is left table in join and second is right table in join (that you passed as `right` param)
  #@return  ActiveRecord::Relation  relation with new join statement
  def construct_advanjo(right, join_type=:inner, alias_name=nil,&block)
    right = right.arel_table if right.class==Class && right.ancestors.include?(ActiveRecord::Base)
    right = right.as_advanjo_sub_query if right.kind_of?(ActiveRecord::Relation)

    right=case right.class.to_s
           when "Advanjo::SubQuery"
             right.arel_table_alias
           when "Arel::Table", "Arel::Nodes::TableAlias"
             right
           when "Symbol"
             Arel::Table.new(right)
           else
             raise "Unsupported right join part passed"
          end

    join_class = (join_type == :outer) ? Arel::Nodes::OuterJoin : Arel::Nodes::InnerJoin

    right=right.alias(alias_name.to_s) unless alias_name.blank?
    alias_statement = arel_table.join(right, join_class)
    alias_statement = alias_statement.on(yield(arel_table, right))

    alias_statement.join_sources.first
  end

  # Construct and add join to your ActiveRecord::Relation object
  def advanjo(*args, &block)
    joins construct_advanjo(*args, &block)
  end

  #LEFT OUTER JOIN
  def outer_advanjo(right, &block)
    advanjo(right, :outer, &block)
  end

  def as_advanjo_sub_query
    Advanjo::SubQuery.new(self)
  end
end
