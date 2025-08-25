import time
import board
import adafruit_bmp280
import adafruit_dht
import json
from datetime import datetime

i2c = board.I2C()
bmp280 = adafruit_bmp280.Adafruit_BMP280_I2C(i2c)
dht_device = adafruit_dht.DHT11(board.D4)  # GPIO4

output_file = "~/sensor_data.json"

try:
    with open(output_file, 'r') as f:
        data_list = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data_list = []

while True:
    try:
        reading = {
            "timestamp": datetime.now().isoformat(),
            "temperature": "{:.2f}".format(bmp280.temperature),
            "pressure": "{:.2f}".format(bmp280.pressure)
        }
    except Exception as e:
        reading = {
            "timestamp": datetime.now().isoformat(),
            "temperature": "Error",
            "pressure": "Error"
        }
        print(f"BMP280 Error: {e}")

    print('Temperature = ' + reading["temperature"] + ' C')
    print('Pressure = ' + reading["pressure"] + ' hPa \n')

    try:
        humidity = dht_device.humidity
        reading["humidity"] = "{:.1f}".format(humidity) if humidity is not None else "Error"
    except RuntimeError as e:
        reading["humidity"] = "Error"
        print(f"DHT11 Error: {e}")

    print('Humidity = ' + reading["humidity"] + ' %')

    data_list.append(reading)
    with open(output_file, 'w') as f:
        json.dump(data_list, f, indent=4)

    time.sleep(4)