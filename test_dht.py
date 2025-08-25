import adafruit_dht
import board
dht_device = adafruit_dht.DHT11(board.D4)
try:
    print(f"Humidity: {dht_device.humidity}%")
except RuntimeError as e:
    print(f"Error: {e}")
