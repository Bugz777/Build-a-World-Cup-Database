#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

do
  # Check winner and opponent teams
  for TEAM in "$WINNER" "$OPPONENT"
  do
    if [[ $TEAM != "winner" && $TEAM != "opponent" ]]
    then
      # Get team_id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      # If not found
      if [[ -z $TEAM_ID ]]
      then
        # insert teams
        INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
        if [[ $INSERT_TEAM == "INSERT 0 1" ]]
        then
          echo "Inserted into teams, $TEAM"
        fi        
      fi
    fi
  done
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" && $ROUND != "round" && $WINNER_GOALS != "winner_goals" && $OPPONENT_GOALS != "opponent_goals" ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    INSERT_MATCH=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_MATCH == "INSERT 0 1" ]]
    then
        echo "Inserted into match, $YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS"
    fi
  fi
done
