require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name:, grade:, id: nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL
      #this returns an empty dogs array
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
end

def save
  sql = <<-SQL
    INSERT INTO students (name, grade)
    VALUES (?, ?)
  SQL

  # insert the dog
  DB[:conn].execute(sql, self.name, self.grade)

  # get the dog ID from the database and save it to the Ruby instance
  self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]

  # return the Ruby instance
  self
end

def self.create(name:, breed:)
  student = Student.new(name: name, grade: grade)
  student.save
end

def self.find_by_name(name)
  sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1
  SQL

  DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
  end.first
end

def update 
  sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.grade, self.id)
end

end