# connect to the databse 
psql --username=freecodecamp --dbname=periodic_table
\c periodic_table 
\d 
\d elements 
\d properties 
#part 1 fix the respository 

# rename the weight column to atomic_mass 
ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;

# update the names of the feature columns to be more informative
ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;
ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;

#they need to be not null 
ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL;
ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL;

##symbol and name need to be unique and not null
ALTER TABLE elements ADD UNIQUE (symbol);
ALTER TABLE elements ADD UNIQUE (name);
ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL;
ALTER TABLE elements ALTER COLUMN name SET NOT NULL;

#set atomic number as a foreign key 
ALTER TABLE properties  ADD FOREIGN KEY (atomic_number) REFERENCES elements(atomic_number);

#create a types table 
CREATE TABLE types(
  type_id SERIAL PRIMARY KEY , 
  type VARCHAR(30) NOT NULL
);

# the three types from the properties table
INSERT INTO types(type) VALUES('nonmetal'), ('metal'), ('metalloid');

#need to capitalize the first letter of the symbol value in the elements table
# Only a few of them need fixing 
UPDATE elements SET symbol = 'He' where symbol = 'he';
UPDATE elements SET symbol = 'Li' where symbol = 'li';
UPDATE elements SET symbol = 'MT' where symbol = 'mT'; 


# add the type_id value into the properties table and pull values from the types table using the type_id foreign key
ALTER TABLE properties ADD COLUMN type_id INT;
ALTER TABLE properties ADD FOREIGN KEY(type_id) REFERENCES types(type_id); 
UPDATE properties SET type_id = types.type_id FROM types WHERE properties.type=types.type;
ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;

#remove the trailing zeros from the atomic mass columns 
ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL;

#HARD CODING - i dont see an easier way 
UPDATE properties SET atomic_mass = 1.008 WHERE atomic_mass = 1.008;
UPDATE properties SET atomic_mass = 4.0026 WHERE atomic_mass = 4.0026;
UPDATE properties SET atomic_mass = 6.94 WHERE atomic_mass = 6.94;
UPDATE properties SET atomic_mass = 9.0122 WHERE atomic_mass = 9.0122;
UPDATE properties SET atomic_mass = 10.81 WHERE atomic_mass = 10.81;
UPDATE properties SET atomic_mass = 12.011 WHERE atomic_mass = 12.011;
UPDATE properties SET atomic_mass = 14.007 WHERE atomic_mass = 14.007;
UPDATE properties SET atomic_mass = 15.999 WHERE atomic_mass = 15.999;
UPDATE properties SET atomic_mass = 1 WHERE atomic_mass = 1;

#inserting new data to the elements and properties table 
#since the atomic number is a foreign key in properties, this one needs to be first.
INSERT INTO elements(atomic_number, symbol, name) 
  VALUES(9, 'F', 'Fluorine'),
        (10, 'Ne', 'Neon');

INSERT INTO properties(atomic_number, type_id, atomic_mass, melting_point_celsius, boiling_point_celsius)
  VALUES(9, 1, 18.998, -220, -188.1),
        (10, 1, 20.18, -248.6, -246.1);
        

#remove erroneous data
DELETE FROM properties WHERE atomic_number = 1000;
DELETE FROM elements WHERE atomic_number = 1000;

#testing to confirm there are no dependencies on type name-- then drop type 
#tye will be pulled from the types table
ALTER TABLE properties RENAME COLUMN type TO hidden;
ALTER TABLE properties DROP COLUMN hidden;

#part 2 create a git respository to record changes to the shell script element.sh
mkdir periodic_table
cd periodic_table 
git init
git checkout -b main 

#part 3 create the shell script element.sh
# that accepts atomic number, symbol, name 
#sql scripts: 
  #PSQL="psql --username=freecodecamp --dbname=<database_name> -t --no-align -c"
touch ./element.sh
chmod +x element.sh

#the shell script will accept atomic number, symbol, or name. 
#testing 
./element.sh 1 
./element.sh H
./element.sh Hydrogen
