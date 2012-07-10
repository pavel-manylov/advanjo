Advanced Joins in your ActiveRecord 3 apps
========================================
Advanjo gives you freedom to create complex joins in ActiveRecord using power of Arel in beautiful way.

Main features
--------------
###Extract sub_query and use it in `advanjo` joins:

    sq = some_active_record_relation_object.as_advanjo_sub_query

  Use Advanjo::SubQuery object as regular Arel::Nodes::TableAlias (or just Arel::Table) in where statements and selects:

    tsq=TemperatureStatistic.group(:city_id).average(:temperature).as_advanjo_sub_query
    cities_ar=City.arel_table
    City.advanjo(tsq){|city,ts| city[:id].eq(ts[:city_id])}.
         where(tsq[:average_temperature].gt(25)).
         select([cities_ar["*"], tsq["average_temperature"].as("temperature")])

###Construct complex join statements ("JOIN something ON <...>") using arel notation:
    City.advanjo(River){|city,river|city[:river_id].eq(river[:id])}
  you can also construct LEFT OUTER JOIN:
    City.outer_advanjo(River){...}
    City.advanjo(River, :outer){...}

###Use anything you want as join source:

    City.advanjo(:rivers){...} #Symbol as table_name
    City.advanjo(Arel::Table.new("rivers")){...}  #Arel::Table instance
    City.advanjo(River.where(...)){...} #ActiveRecord::Relation instance
    City.advanjo(River){...} #ActiveRecord model