#!/bin/bash
# This script is a function to pull information of a given element based on user entry. 
#User may enter atomic number, symbol, or name to refer to a given element.


PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

#if an argument is inserted
if [[ $1 ]]
then 

  #The argument could be: atomic_number, symbol, name
  #if an atomic number 
  FAIL=TRUE #fail flag to determine if a valid value was entered 
  if [[ $1 =~ ^[0-9]+$ ]] #if entry is a number
  then 
    #pull atomic number from the table to comfirm this is an element we already have recorded. 
    CHECK=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
    if [[ $CHECK ]]
    then
      #assign values for message 
      ATOMIC_NUMBER=$1
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$1")
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$1")
      FAIL=FALSE
    else 
      #the atomic number did not match our table / or the value entered was an invalid integer
      FAIL=TRUE
    fi
  else 
    # if entry is not a number, could be symbol or name 
    
    #if it is a symbol
    #determine by matching to the symbol table 
    CHECK=$($PSQL "SELECT symbol FROM elements WHERE symbol='$1'")
    if [[ $CHECK ]]
    then 
      #pull dimensions for element
      SYMBOL=$CHECK
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
      NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$1'")
      FAIL=FALSE
    fi 
    
    #if it is a name 
    #determine by matching to the name elements table
    CHECK=$($PSQL "SELECT name FROM elements WHERE name='$1'")
    if [[ $CHECK ]]
    then 
      #pull dimensions for element
      NAME=$CHECK
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$1'")
      FAIL=FALSE
    fi 
    
  fi
  
  if [[ $FAIL = TRUE ]]
  then 
    #aka the value entered was not found in the table
    echo "I could not find that element in the database."
  else 
    #using this info we need to pull more info from the properties table for the message <3
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
  # no value was entered (no argument passed)
  echo "Please provide an element as an argument."
fi
