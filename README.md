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
Users are also able to use the `SQLObject::find(id)` method to find a specific object via 
