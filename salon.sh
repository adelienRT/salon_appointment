#! /bin/bash

#PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
  echo -e "\n$1\n"
  fi

  SERVICES=$($PSQL "SELECT service_id,name FROM services;")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
  echo -e "$SERVICE_ID)$NAME"
  done
  SERVICE_ID
}

SERVICE_ID(){
  # select a service
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
  REGISTER $SERVICE_ID_SELECTED
  else
  MAIN_MENU "I could not find that service. What would you like today?"
  fi
}

REGISTER(){
  # SERVICE_ID_SELECTED, CUSTOMER_PHONE, CUSTOMER_NAME, and SERVICE_TIME
  SERVICE_NAME_INIT=$($PSQL "SELECT name FROM services WHERE service_id=$1;")
  SERVICE_NAME=$(echo $SERVICE_NAME_INIT | sed 's/ |/"/')
  # if not a valid service number
  if [[ -z $SERVICE_NAME ]]
  then
    # go back to the list of services MAIN_MENU
    MAIN_MENU "I could not find that service. What would you like today?"
  else

  # if it is a valid service number
  SERVICE_ID_SELECTED=$1
  # ask for a phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME_INIT=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME_INIT | sed 's/ |/"/')

   # if not a number existant
   if [[ -z $CUSTOMER_NAME ]]
   then
    # Ask for a name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME');")
    fi
    # look at the customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")


  # Ask for the time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')";)
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi

}

MAIN_MENU "Welcome to My Salon, how can I help you?"
