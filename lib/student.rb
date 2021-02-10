require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id
  
  
  def initialize(name, grade, id = nil)
    self.name = name
    self.grade = grade
    @id = id
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
    end
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(student)
      Student.new(student[1], student[2], student[0]) 
  end

  def self.find_by_name(name)
    sql =  <<-SQL
    SELECT * FROM students
    WHERE name = ?
      SQL
    student_db = DB[:conn].execute(sql, name)
    self.new_from_db(student_db.first)

  end

  def self.create_table 
    sql =  <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
      )
      SQL
  DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

end
