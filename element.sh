#!/bin/bash



PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

#if an argument is inserted
if [[ $1 ]]
then 
  
  #The argument could be: atomic_number, symbol, name
  #if an atomic number 
  FAIL=TRUE
  if [[ $1 =~ ^[0-9]+$ ]]
  then 
    CHECK=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
    if [[ $CHECK ]]
    then
      ATOMIC_NUMBER=$1
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$1")
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$1")
      FAIL=FALSE
    else 
      FAIL=TRUE
    fi
  else 

    #could be symbol or name 
    #if it is a symbol
      #determine by matching to the symbol table 
    CHECK=$($PSQL "SELECT symbol FROM elements WHERE symbol='$1'")
    if [[ $CHECK ]]
    then 
      SYMBOL=$CHECK
      
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
      NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$1'")
      FAIL=FALSE
    fi 
    
    #if it is a name 
      #determine by matching to the name
    CHECK=$($PSQL "SELECT name FROM elements WHERE name='$1'")
    if [[ $CHECK ]]
    then 
      NAME=$CHECK
      
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$1'")
      FAIL=FALSE
    fi 
    
  fi
  
  if [[ $FAIL = TRUE ]]
  then 
    echo "I could not find that element in the database."
  else 
    #using this info we need to pull more info <3
    # info to pull: atomic_mass, melting_point_celsius, boiling_point_celsius, type
    # need to pull type from types table with type_id from 


    ATOMIC_MASS=$($PSQL "SELECT properties.atomic_mass FROM properties \
      INNER JOIN types ON properties.type_id = types.type_id \
      WHERE properties.atomic_number=$ATOMIC_NUMBER")
    MELTING_POINT=$($PSQL "SELECT properties.melting_point_celsius FROM properties \
      INNER JOIN types ON properties.type_id = types.type_id \
      WHERE properties.atomic_number=$ATOMIC_NUMBER")
    BOILING_POINT=$($PSQL "SELECT properties.boiling_point_celsius FROM properties \
      INNER JOIN types ON properties.type_id = types.type_id \
      WHERE properties.atomic_number=$ATOMIC_NUMBER")
    TYPE=$($PSQL "SELECT types.type FROM properties \
      INNER JOIN types ON properties.type_id = types.type_id \
      WHERE properties.atomic_number=$ATOMIC_NUMBER")
    

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi 
else 
  echo "Please provide an element as an argument."
fi