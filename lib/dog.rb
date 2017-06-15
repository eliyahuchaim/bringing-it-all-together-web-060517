require 'pry'

class Dog

 attr_accessor :name, :breed, :id
 # attr_reader :id

 def initialize(dog_hash)
   @name = dog_hash[:name]
   @breed = dog_hash[:breed]
   dog_hash[:id] ? @id = dog_hash[:id] : @id = nil
 end

 def self.create_table
   sql = <<-SQL
   CREATE TABLE IF NOT EXISTS dogs (
     id integer primary key,
     name text,
     breed text
   )
  SQL
  DB[:conn].execute(sql)
 end

 def self.drop_table
   sql = <<-SQL
   DROP TABLE dogs
   SQL
   DB[:conn].execute(sql)
 end

 def save
   sql = <<-SQL
   INSERT INTO dogs (name, breed)
   VALUES (?, ?)
   SQL
   DB[:conn].execute(sql, self.name, self.breed)
  #  binding.pry
   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
   self
 end

 def self.new_from_db(dog_row)
   new_dog = Dog.new({:id => dog_row[0], :name => dog_row[1], :breed => dog_row[2]})
   new_dog
 end


 def self.create(hash)
   hash.class == Hash
   hash.class == Hash
   new_dog = Dog.new(hash)
   new_dog.name = hash[:name]
   new_dog.breed = hash[:breed]
   new_dog.save
 end


 def self.find_by_id(id)
   sql = <<-SQL
   SELECT * FROM dogs
   WHERE id = ?
   SQL
   return_value = DB[:conn].execute(sql, id).first
   dog = Dog.new_from_db(return_value)
   dog
 end

 def self.find_or_create_by(hash)
   # binding.pry
   find_dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
   if !find_dog.empty?
     new_dog = find_dog[0]
     find_dog = self.new_from_db(new_dog)
   else
   self.create(hash)
   end
 end

 def self.find_by_name(name)
   sql = <<-SQL
   SELECT * FROM dogs
   WHERE name = ?
   SQL
   return_value = DB[:conn].execute(sql, name)[0]
   self.new_from_db(return_value)
 end

 def update
   sql = <<-SQL
   UPDATE dogs
   SET name = ?, breed = ? WHERE id = ?
   SQL
   DB[:conn].execute(sql, self.name, self.breed, self.id)
 end

end
