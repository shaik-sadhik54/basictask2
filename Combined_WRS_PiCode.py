import sys
from urllib.request import urlopen
import RPi.GPIO as GPIO
import bmpsensor
from time import sleep
import requests

# GPIO Setup
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)

# Sensor Pins
channel = 26  # Rain sensor
humidity_pin = 27  # Humidity sensor

# Actuation Pins
pin1 = 23
pin2 = 24
alert_pin = 21

# GPIO Setup
GPIO.setup(channel, GPIO.IN)
GPIO.setup(humidity_pin, GPIO.IN)
GPIO.setup(pin1, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(pin2, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(alert_pin, GPIO.OUT, initial=GPIO.LOW)

# ThingSpeak API Keys
myAPI = 'YOUR_THINGSPEAK_API_KEY'
read_api_key = 'YOUR_THINGSPEAK_READ_API_KEY'
channel_id = 'YOUR_CHANNEL_ID'

# ThingSpeak URLs
baseURL = 'https://api.thingspeak.com/update?api_key=%s' % myAPI
baseURL_read = 'https://api.thingspeak.com/channels/%s/feeds.json?api_key=%s' % (channel_id, read_api_key)


def bmp_data():
    temp, press, alt = bmpsensor.readBmp180()
    return temp, press, alt


def main():
    for x in range(5):
        temp, press, alt = bmp_data()

        # Weather Data Display
        print('WEATHER MONITORING SYSTEM - PROJECT 1')
        print('-------------------------------------------------------')
        print('Temperature: %.2f C' % temp)
        print('Pressure:    %.2f hPa' % (press / 100.0))

        # Rain Detection
        if GPIO.input(channel):
            rain = 0
            print('No Rain')
        else:
            rain = 1
            print('Raining!')

        # Humidity Reading
        humidity = GPIO.input(humidity_pin)
        print('Humidity:    %.2f' % humidity)

        # Update ThingSpeak
        conn = urlopen(baseURL + '&field1=%.2f&field2=%.2f&field3=%d&field4=%d' % (temp, press, humidity, rain))
        print(conn.read())
        conn.close()

        # Alert System
        alerts = requests.get(baseURL_read).json()['feeds'][0]
        if float(alerts['field1']) > 28:
            print("It's a VERY hot day")
            GPIO.output(pin1, 1)
            GPIO.output(pin2, 0)
        else:
            print("It's a Normal day")
            GPIO.output(pin2, 1)
            GPIO.output(pin1, 0)

        if float(alerts['field2']) < 970:
            print("It's a windy day")
            GPIO.output(alert_pin, 1)
        else:
            GPIO.output(alert_pin, 0)

        # Wait before next iteration
        sleep(30)
        print('-------------------------------------------------------')
        GPIO.output(pin1, 0)
        GPIO.output(pin2, 0)
        GPIO.output(alert_pin, 0)


if __name__ == "__main__":
    main()
