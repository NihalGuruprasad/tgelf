import time
import board
import adafruit_bmp280
#from pms5003 import PMS5003
import Adafruit_DHT
import json
from datetime import datetime

i2c = board.I2C()

bmp280 = adafruit_bmp280.Adafruit_BMP280_I2C(i2c)

#pms5003 = PMS5003(device="/dev/ttyAMA0", baudrate=9600, pin_enable="GPIO22", pin_reset="GPIO27")

DHT_SEN = 11
DHT_P = 4

# File to store JSON data
output_file = "sensor_data.json"

# Initialize or load existing JSON data
try:
    with open(output_file, 'r') as f:
        data_list = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data_list = []

while True:
    # Create a dictionary for the current reading
    reading = {
        "timestamp": datetime.now().isoformat(),
        "temperature": "{:.2f}".format(bmp280.temperature),
        "pressure": "{:.2f}".format(bmp280.pressure)
    }
    
    print('Temperature = ' + reading["temperature"] + ' C')
    print('Pressure = ' + reading["pressure"] + ' hPa \n')
    
#    try:
#        pms_data = pms5003.read()
#        reading["pms5003"] = str(pms_data)
#    except Exception as e:
#        pms_data = f"Error Reading: {e}"
#        reading["pms5003"] = pms_data
    
#    print('PMS5003: ' + reading["pms5003"])

    humidity = Adafruit_DHT.read_retry(DHT_SEN, DHT_P)
    reading["humidity"] = "{:.1f}".format(humidity) if humidity is not None else "Error"
    
    print('Humidity = ' + reading["humidity"] + ' %')

    # Append the reading to the data list
    data_list.append(reading)
    
    # Write the updated data list to the JSON file
    with open(output_file, 'w') as f:
        json.dump(data_list, f, indent=4)

    time.sleep(4)
