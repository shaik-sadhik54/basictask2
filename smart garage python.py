import conf
import json
import time
from boltiot import Bolt, Sms

# Initialize Bolt and Twilio SMS
mybolt = Bolt(conf.API_KEY, conf.DEVICE_ID)
sms = Sms(conf.SID, conf.AUTH_TOKEN, conf.TO_NUMBER, conf.FROM_NUMBER)

# Initialize variables
old_state = 0  # Variable to save previous state information initialized to 0

while True:
    print("Reading value from Bolt")
    response = mybolt.digitalRead('1')
    data = json.loads(response)
    print(data)
    new_state = int(data['value'])  # Retrieving new_state from the data

    if old_state != new_state:  # Checking for change in state
        # Change in state indicates that the garage door is opened or closed
        try:
            if new_state == 1:  # Value of new_state is 1 implies that garage door is open
                print("Garage is open, performing additional checks...")

                # Add code for laser detection
                # if laser detection logic here
                #    perform action or send notification

                # Add code for voice commands detection
                # if voice command detected
                #    perform action or send notification

                print("Making request to Twilio to send SMS")  # Sending an SMS to the TO NUMBER
                response = sms.send_sms("Garage is open")
                print("Response received from Twilio is:", str(response))
                print("Status of SMS at Twilio is:", str(response.status))

            elif new_state == 0:  # Value of new_state is 0 implies that garage door is closed
                print("Garage is closed, performing additional checks...")

                # Add code for laser detection
                # if laser detection logic here
                #    perform action or send notification

                # Add code for voice commands detection
                # if voice command detected
                #    perform action or send notification

                print("Making request to Twilio to send SMS")  # Sending an SMS to the TO NUMBER
                response = sms.send_sms("Garage is closed")
                print("Response received from Twilio is:", str(response))
                print("Status of SMS at Twilio is:", str(response.status))

        except Exception as e:
            print("Error occurred: Below are the details")
            print(e)

    old_state = new_state  # Assign new_state value to the old_state for the next cycle
    time.sleep(20)  # Wait for 20 seconds
