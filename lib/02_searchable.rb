require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  # p "hello"
  def where(params)
    where_string = params.keys.map do |key|
      (key.to_s).concat(" = ?")
    end.join(" AND ")
    # where_string = params.keys.map(&:to_s).map(&:concat(" = ?")).join(" AND ") #Not working
    results = DBConnection.instance.execute(<<-SQL, params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_string}
    SQL
    parse_all(results)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
