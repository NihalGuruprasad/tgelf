import time
import board
import adafruit_bmp280
from pms5003 import PMS5003
import Adafruit_DHT

i2c = board.I2C()

bmp280 = adafruit_bmp280.Adafruit_BMP280_I2C(i2c)

pms5003 = PMS5003(device="/dev/ttyAMA0", baudrate=9600, pin_enable="GPIO22", pin_reset="GPIO27")

DHT_SEN = 11
DHT_P = 4

while True:
    temp = bmp280.temperature
    pres = bmp280.pressure
    format_t = "{:.2f}".format(temp)
    print('Temperature = ' + format_t + ' C')
    format_p = "{:.2f}".format(pres)
    print('Pressure = ' + format_p + ' hPa \n')
    
    try:
        pms_data = pms5003.read()
    except Exception as e:
        pms_data = f"Error Reading: {e}"
    
    print('PMS5003: ' + pms_data)

    humidity = Adafruit_DHT.read_retry(DHT_SEN, DHT_P)
    format_h = "{:.1f}".format(humidity) if humidity is not None else "Error"

    print('Humidity = ' + format_h + ' %')


    time.sleep(4)
