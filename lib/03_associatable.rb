require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name == 'Human' ? 'humans' : @class_name.tableize
  end

  # def assignment(name, options = {})
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    # if options.empty?
    #   @class_name = name.singularize.camelcase
    #   @primary_key = :id
    #   @foreign_key = (name + "Id").underscore.to_sym
    # else
    #   @class_name ||= options[:class_name]
    #   @primary_key ||= options[:primary_key]
    #   @foreign_key ||= options[:foreign_key]
    # end

    @class_name = options[:class_name].nil? ? name.singularize.camelcase : options[:class_name]
    @primary_key = options[:primary_key].nil? ? :id : options[:primary_key]
    @foreign_key = options[:foreign_key].nil? ? (name + "Id").underscore.to_sym : options[:foreign_key]

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    # if options.empty?
    #   @class_name = name.singularize.camelcase
    #   @primary_key = :id
    #   @foreign_key = (self_class_name + "Id").underscore.to_sym
    # else
    #   @class_name ||= options[:class_name]
    #   @primary_key ||= options[:primary_key]
    #   @foreign_key ||= options[:foreign_key]
    # end
    @class_name = options[:class_name].nil? ? name.singularize.camelcase : options[:class_name]
    @primary_key = options[:primary_key].nil? ? :id : options[:primary_key]
    @foreign_key = options[:foreign_key].nil? ? (self_class_name + "Id").underscore.to_sym : options[:foreign_key]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    # if options.empty?
    #   options = BelongsToOptions.new(name.to_s)
    # else
    #   options = BelongsToOptions.new(name.to_s, options)
    # end
    options = BelongsToOptions.new(name.to_s, options)
    assoc_options
    @assoc_options[name] = options
    define_method "#{name}" do
      # foreign_key_value = )
      # p options.model_class.name
      # p self.send(options.foreign_key).class
      # p "HHHHHHHHHHHHKKFJEKJDFKJDF"
      options.model_class.where({:id => self.send(options.foreign_key)}).first
    end

  end

  def has_many(name, options = {})
  #   # ..
    # p self.name
    # p self.id

    options = HasManyOptions.new(name.to_s, self.name, options)
    # p options
    define_method "#{name}" do
      # p options.foreign_key
      options.model_class.where({options.foreign_key => self.id})
    end
  end

  # def assoc_options[]=(*args)
  #   p args
  #   # p obj
  #   # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  #   @assoc_options ||= {}
  #   @assoc_options[key] = obj
  # end
  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
    # @assoc_options[name] = options
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
