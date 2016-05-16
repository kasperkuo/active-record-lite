## Overview

NAME is a custom object-relational mapping (ORM) tool used to query the database.

## Functionality

NAME wraps SQL objects in Ruby to allow for object oriented programming. The SQL object has a `SQLObject::all` method that queries the database and returns all objects from a specific table `self.table_name`.

```
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

```
Users are able to use the `SQLObject::find(id)` method to find a specific object via an id. They can also use `SQLObject#insert`, `SQLObject#update`, and `SQLObject#save` to modify the table.

## Search

Users can use the where method to find data from the table. It is a module utilized in SQLObject.

```
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
```

## Associations

Another functionality of NAME is the ability to map out relations. It has a parent class `AssocOptions`, which contains attribute accessors for `:foreign_key`, `:class_name`, and `:primary_key`. Two other classes `BelongsToOptions` and `HasManyOptions` both inherit from `AssocOptions` and serve as the backbone to our relations.

There also exists an `Associatable` module, which house the three methods `belongs_to`, `has_many`, and `has_one_through`. An example of the method is shown below:

```  
def belongs_to(name, options = {})
  self.assoc_options[name] = BelongsToOptions.new(name, options)
  define_method(name) do
    options = self.class.assoc_options[name]
    foreign_key = self.send(options.foreign_key)
    class_name = options.model_class
    class_name.where(options.primary_key => foreign_key).first
  end
end
```
These methods use metaprogramming to help query the database to filter out specific results based on the table name. It essentially takes the `assoc_options` hash and extracts the foreign key. When querying the database, it uses the `where` method to match any foreign key with the primary key.

## Future Implementations

- Validation methods
- `has_many :through` associations that allows us to create join tables
- `includes` and `joins` methods
