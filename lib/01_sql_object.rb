require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    results = DBConnection.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        '#{table_name}'
    SQL
    results.first.keys.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |col|
      # p col
      # ins_var_sym = "@#{col.to_s}".to_sym
      define_method "#{col}" do
        @attributes[col]
      end

      define_method "#{col}=" do |obj|
        attributes({col => obj})
      end

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    # ...

    @table_name = name == 'Human' ? 'humans' : name.tableize if @table_name == nil

      # @table_name ||= name.tableize
    return @table_name
  end

  def self.all
    # ...
    results = DBConnection.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        '#{table_name}'
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    # ...
    # results.each.keys.map! { |key| key.to_sym}
    # p results
    results.map do |result|
      # p result

      params = {}
      result.each_pair do |key, value|
        params[key.to_sym] = value
      end
      self.new(params)
    end
  end

  def self.find(id)
    # ...
    self.all.find { |obj| obj.id == id}
  end

  def initialize(params = {})
    # p params
    params.keys.each do |key|
      # next if key == :id
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key)
    end
    attributes(params)
  end

  def attributes(attr_hash = {})
    @attributes ||= {}
    @attributes.merge!(attr_hash)
  end

  def attribute_values(col = self.class.columns)
    col.map {|col| @attributes[col]}
  end

  def insert
    # ...
    col_names = self.class.columns
    # p col_names
    col_names.delete(:id)
    # p col_names
    # values = col_names.map {|col| @attributes[col]}
    values = attribute_values(col_names)
    question_marks = ["?"] * col_names.count
    DBConnection.instance.execute(<<-SQL, values)
      INSERT INTO
        #{self.class.table_name} (#{col_names.join(", ")})
      VALUES
        (#{question_marks.join(", ")})
    SQL
    @attributes[:id] = DBConnection.last_insert_row_id
    attribute_values
  end

  def update
    # ...
    col_names = self.class.columns
    col_names.delete(:id)
    values = attribute_values(col_names)
    values << @attributes[:id]
    set_arr = col_names.map do |col|
      col.to_s + " = ?"
    end
    # p set_arr
    DBConnection.instance.execute(<<-SQL, values)
      Update
        '#{self.class.table_name}'
      SET
        #{set_arr.join(", ")}
      WHERE
        id = ?
    SQL
  end

  def save
    # ...
    @attributes[:id].nil? ? insert : update

  end
end
