#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\nWelcome to My Salon."

MAIN_MENU () {
SERVICES=$($PSQL "select * from services")
echo -e "\nPlease select a service from the following menu:\n"
echo "$SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done
read SERVICE_ID_SELECTED
# is input a number
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  # if not send to main menu
  echo -e "\nThat is not a valid choice. Please try again."
  MAIN_MENU
else
  # get service name
  SELECTED_SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
  # if service name doesn't exist - (0 rows) - send to main menu
  if [[ -z $SELECTED_SERVICE_NAME ]]
  then
    echo -e "\nThat is not a valid choice. Please try again."
    MAIN_MENU
  fi
fi
}

MAIN_MENU
echo -e "\nWhat is your phone number?\n"
read CUSTOMER_PHONE
# check if phone number exists
CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
# if not get name
if [[ -z $CUSTOMER_ID ]]
then
  echo "What is your name?"
  read CUSTOMER_NAME
  INSERT_NAME_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "select name from customers where customer_id = $CUSTOMER_ID")
fi

echo -e "What time would you like your $SELECTED_SERVICE_NAME, $CUSTOMER_NAME"
read SERVICE_TIME
INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id,service_id,time) values ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

echo -e "\nI have put you down for a $SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

