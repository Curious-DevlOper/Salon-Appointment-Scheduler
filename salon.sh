#!/bin/bash



# Display welcome message and available services
display_services() {
  echo -e "\n~~~~~ MY SALON ~~~~~"
  echo -e "\nWelcome to My Salon, how can I help you?"

  # Retrieve and display services with the required format: 1) cut
  psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT service_id, name FROM services ORDER BY service_id;" | while IFS="|" read SERVICE_ID NAME; do
    echo "$SERVICE_ID) $NAME"
  done
}

# Function to handle appointment scheduling
schedule_appointment() {
  # Display services before the first prompt for input
  display_services

  # Prompt for service selection
  read SERVICE_ID_SELECTED

  # Check if the selected service exists
  SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nI could not find that service. What would you like today?"
    schedule_appointment
    return
  fi

  # Prompt for customer phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Check if the customer exists
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]; then
    # New customer, prompt for their name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
  fi

  # Prompt for appointment time
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  # Get customer_id
  CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Insert the appointment
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

  # Output confirmation message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Run the appointment scheduler
schedule_appointment
