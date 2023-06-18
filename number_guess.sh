#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$((RANDOM%1000+1))
echo $NUMBER
echo "Enter your username:"
read USERNAME

GETUSERNAME=$($PSQL "select username,games_played,best_game from usernames where username='$USERNAME';")

if [[ -z $GETUSERNAME ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo $GETUSERNAME | while IFS="|" read USER GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

NUMBER_GUESSES=0
echo "Guess the secret number between 1 and 1000:"
function GUESS {
  NUMBER_GUESSES=$((NUMBER_GUESSES + 1))
  read GUESS_NUM
  if [[ "$GUESS_NUM" =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS_NUM -lt $1 ]]
    then
      echo "It's lower than that, guess again:"
      GUESS $NUMBER
    elif [[ $GUESS_NUM -gt $1 ]]
    then
      echo "It's higher than that, guess again:"
      GUESS $NUMBER
    elif [[ $GUESS_NUM -eq $1 ]]
    then
      echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $NUMBER. Nice job!"
      if [[ -z $GETUSERNAME ]]
      then
        INSERT_USER=$($PSQL "insert into usernames(username,games_played,best_game) values('$USERNAME',1,$NUMBER_GUESSES);")
      else
        echo $GETUSERNAME | while IFS="|" read USER GAMES_PLAYED BEST_GAME
        do
          if [[ $NUMBER_GUESSES -lt $BEST_GAME ]]
          then
            UPDATE_USER=$($PSQL "update usernames set games_played = games_played + 1,best_game = $NUMBER_GUESSES where username = '$USERNAME'")
          else
            UPDATE_USER=$($PSQL "update usernames set games_played = games_played + 1 where username = '$USERNAME'")
          fi
        done
      fi
    fi
  else
    echo "That is not an integer, guess again:"
    GUESS $NUMBER
  fi
}

GUESS $NUMBER



