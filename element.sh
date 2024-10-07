#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

GET_REMAINING_INFO() {
  TYPE_ID=$(echo $($PSQL "SELECT type_id FROM properties WHERE atomic_number=$1") | sed 's/^ *| *$//g')
    
  TYPE=$(echo $($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID") | sed 's/^ *| *$//g')

  ATOMIC_MASS=$(echo $($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$1") | sed 's/^ *| *$//g')

  MELTING_POINT=$(echo $($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$1") | sed 's/^ *| *$//g')

  BOILING_POINT=$(echo $($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$1") | sed 's/^ *| *$//g')

  echo -e "The element with atomic number $1 is $3 ($2). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $3 has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
}

if [[ $1 ]]
then
  # check if an argument is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$(echo $($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1") | sed 's/^ *| *$//g')

    # check if the number is in a database
    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo I could not find that element in the database.
    else
      SYMBOL=$(echo $($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER") | sed 's/^ *| *$//g')

      NAME=$(echo $($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER") | sed 's/^ *| *$//g')

      GET_REMAINING_INFO "$ATOMIC_NUMBER" "$SYMBOL" "$NAME"
    fi
  else
    SYMBOL=$(echo $($PSQL "SELECT symbol FROM elements WHERE symbol='$1'") | sed 's/^ *| *$//g')

    NAME=$(echo $($PSQL "SELECT name FROM elements WHERE name='$1'") | sed 's/^ *| *$//g')

    if [[ -z $SYMBOL ]]
    then
      if [[ -z $NAME ]]
      then
        echo I could not find that element in the database.
      else
        ATOMIC_NUMBER=$(echo $($PSQL "SELECT atomic_number FROM elements WHERE name='$NAME'") | sed 's/^ *| *$//g')

        SYMBOL=$(echo $($PSQL "SELECT symbol FROM elements WHERE name='$NAME'") | sed 's/^ *| *$//g')

        GET_REMAINING_INFO "$ATOMIC_NUMBER" "$SYMBOL" "$NAME"
      fi
    else
      ATOMIC_NUMBER=$(echo $($PSQL "SELECT atomic_number FROM elements WHERE symbol='$SYMBOL'") | sed 's/^ *| *$//g')

      NAME=$(echo $($PSQL "SELECT name FROM elements WHERE symbol='$SYMBOL'") | sed 's/^ *| *$//g')

      GET_REMAINING_INFO "$ATOMIC_NUMBER" "$SYMBOL" "$NAME"
    fi
  fi
else
  echo Please provide an element as an argument.
fi
