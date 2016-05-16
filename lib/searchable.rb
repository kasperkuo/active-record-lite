require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    table = self.table_name
    where_line = params.map { |k, v| "#{table}.#{k} = '#{v}'" }.join(" AND ")
    data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table}
      WHERE
        #{where_line}
    SQL
    data.map { |datum| self.new(datum) }
  end
end

class SQLObject
  extend Searchable
end
