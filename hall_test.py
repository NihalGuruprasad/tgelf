import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)
HALL_SENSOR_PIN = 18
GPIO.setup(HALL_SENSOR_PIN, GPIO.PIN)

try:
    while True:
        if GPIO.input(HALL_SENSOR_PIN) == GPIO.LOW:
            print("YES")
        else
            print("NO")
        time.sleep(1)
except KeyboardInterrupt:
    print("\nProgram terminated by user")
finally:
    GPIO.cleanup()
