require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject

  def self.columns
    table = table_name
    if @data == nil
      @data = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          '#{table}'
      SQL
    else
      @data
    end
    @data.first.map { |col| col.to_sym }
  end

  def self.finalize!
    columns.each do |column_name|
      define_method(column_name) do
        attributes[column_name]
      end

      define_method("#{column_name}=") do |arg|
        attributes[column_name] = arg
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    table = table_name
    data ||= DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table}
    SQL

    parse_all(data)
  end

  def self.parse_all(results)
    results.map { |object| self.new(object) }
  end

  def self.find(id)
    return nil if id.nil?
    table = table_name
    object = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table}
      WHERE
        #{table}.id = #{id}
    SQL

    object.first ? self.new(object.first) : nil
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name_sym = attr_name.to_sym
      columns = self.class.columns
      if !columns.include?(attr_name_sym)
        raise "unknown attribute '#{attr_name_sym}'"
      else
        send("#{attr_name}=", value)
      end
    end
  end

  def attributes
    @attributes ||= {}

  end

  def attribute_values
    attributes.values
  end

  def insert
    col_names = self.class.columns.drop(1).join(", ")
    question_marks = (["?"] * (self.class.columns.length - 1)).join(", ")
    table = self.class.table_name
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{table} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    line = self.class.columns.map { |attr| "#{attr} = ?"}
    set_line = line.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    if self.class.find(self.id)
      self.update
    else
      self.insert
    end
  end
end
