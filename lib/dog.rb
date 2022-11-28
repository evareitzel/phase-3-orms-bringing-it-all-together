class Dog

  attr_accessor :name,:breed, :id

  def initialize (name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    # drop Dogs  table from DB
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES(?, ?)
    SQL

    # insert new dog record to DB
    DB[:conn].execute(sql, self.name, self.breed)

    # save dog to Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    # return Ruby instance
    self
  end

  def self.create(name:, breed:)
    # create new row in DB
    dog = Dog.new(name: name, breed: breed)
    # return Dog class instance
    dog.save
  end

  def self.new_from_db(row) # aka new_from_arr
    # constructor method - returns class instance w/o overwriting initialize
    # cast data to appropriate dog attrs
    # return arr representing dog's data

    # self.new is equivalent to dog.new
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM dogs
    SQL
  # return arr of Dog instances
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    # return instance of searched Dog class w all dog properties
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find(id)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    # return single Dog instance
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  # BONUS methods
  # .find_or_create_by
  # .update
  # .save (expanded)

end
