#!/bin/bash

# Exit on any error
set -e

echo "Starting setup for sensor script dependencies..."

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required system packages
echo "Installing system dependencies..."
sudo apt install -y python3-pip libgpiod2 i2c-tools

# Enable I2C interface
echo "Enabling I2C interface..."
sudo raspi-config nonint do_i2c 0

# Verify I2C is enabled
if ls /dev/i2c-* >/dev/null 2>&1; then
    echo "I2C interface enabled successfully."
else
    echo "Error: I2C interface not detected. Please check hardware or configuration."
    exit 1
fi

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install --user adafruit-circuitpython-bmp280 adafruit-blinka

# Install Adafruit_Python_DHT (older library, may require manual installation)
echo "Installing Adafruit_Python_DHT..."
if ! pip3 install --user Adafruit_DHT; then
    echo "Warning: Adafruit_Python_DHT installation failed. Attempting to install from source..."
    git clone https://github.com/adafruit/Adafruit_Python_DHT.git /tmp/Adafruit_Python_DHT
    cd /tmp/Adafruit_Python_DHT
    sudo python3 setup.py install
    cd -
    rm -rf /tmp/Adafruit_Python_DHT
fi

# Install fallback DHT library (adafruit-circuitpython-dht) for compatibility
echo "Installing adafruit-circuitpython-dht as fallback..."
pip3 install --user adafruit-circuitpython-dht

# Ensure write permissions for sensor_data.json in the home directory
echo "Setting up permissions for sensor_data.json..."
touch ~/sensor_data.json
chmod 666 ~/sensor_data.json

# Verify I2C device detection (for BMP280)
echo "Checking for I2C devices (BMP280)..."
if i2cdetect -y 1 | grep -q "77"; then
    echo "BMP280 detected at I2C address 0x77."
elif i2cdetect -y 1 | grep -q "76"; then
    echo "BMP280 detected at I2C address 0x76."
else
    echo "Warning: No BMP280 detected on I2C bus. Check wiring or sensor."
fi

echo "Setup complete! You can now run the Python script."
echo "Note: If DHT11 readings fail, try running the script with 'sudo python3 your_script.py'."
