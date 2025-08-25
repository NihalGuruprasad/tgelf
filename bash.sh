#!/bin/bash

# Exit on any error
set -e

# Check if script is run with executable permissions
if [ ! -x "$0" ]; then
    echo "Error: Script lacks executable permissions. Fixing..."
    chmod +x "$0"
    echo "Please re-run the script: ./$0"
    exit 1
fi

echo "Starting setup for sensor script dependencies..."

# Check for internet connectivity
echo "Checking internet connectivity..."
if ! ping -c 1 google.com >/dev/null 2>&1; then
    echo "Error: No internet connection. Please connect to the internet and try again."
    exit 1
fi

# Update system packages
echo "Updating system packages..."
if ! sudo apt update; then
    echo "Error: Failed to update package lists. Check internet or repository settings."
    exit 1
fi
sudo apt upgrade -y

# Install required system packages
echo "Installing system dependencies..."
sudo apt install -y python3-pip python3-venv libgpiod2 i2c-tools git

# Enable I2C interface
echo "Enabling I2C interface..."
if ! sudo raspi-config nonint do_i2c 0; then
    echo "Error: Failed to enable I2C. Check if raspi-config is installed."
    exit 1
fi

# Verify I2C is enabled
if ls /dev/i2c-* >/dev/null 2>&1; then
    echo "I2C interface enabled successfully."
else
    echo "Error: I2C interface not detected. Please check hardware or configuration."
    exit 1
fi

# Create and activate a virtual environment
VENV_DIR=~/sensor_venv
echo "Creating virtual environment in $VENV_DIR..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# Install Python dependencies in the virtual environment
echo "Installing Python dependencies in virtual environment..."
if ! pip install adafruit-circuitpython-bmp280 adafruit-blinka; then
    echo "Error: Failed to install BMP280 or Blinka libraries. Check pip and internet."
    deactivate
    exit 1
fi

# Install Adafruit_Python_DHT
echo "Installing Adafruit_Python_DHT..."
if ! pip install Adafruit_DHT; then
    echo "Warning: Adafruit_Python_DHT installation failed. Attempting to install from source..."
    if ! git clone https://github.com/adafruit/Adafruit_Python_DHT.git /tmp/Adafruit_Python_DHT; then
        echo "Error: Failed to clone Adafruit_Python_DHT repository."
        deactivate
        exit 1
    fi
    cd /tmp/Adafruit_Python_DHT
    if ! python3 setup.py install; then
        echo "Error: Failed to install Adafruit_Python_DHT from source."
        cd -
        rm -rf /tmp/Adafruit_Python_DHT
        deactivate
        exit 1
    fi
    cd -
    rm -rf /tmp/Adafruit_Python_DHT
fi

# Install fallback DHT library
echo "Installing adafruit-circuitpython-dht as fallback..."
if ! pip install adafruit-circuitpython-dht; then
    echo "Warning: Failed to install adafruit-circuitpython-dht. DHT11 may require sudo."
fi

# Deactivate virtual environment
deactivate

# Ensure write permissions for sensor_data.json
echo "Setting up permissions for sensor_data.json..."
JSON_FILE=~/sensor_data.json
if ! touch "$JSON_FILE"; then
    echo "Error: Cannot create $JSON_FILE. Check directory permissions."
    exit 1
fi
chmod 666 "$JSON_FILE"

# Verify I2C device detection (for BMP280)
echo "Checking for I2C devices (BMP280)..."
if i2cdetect -y 1 | grep -q "77" || i2cdetect -y 1 | grep -q "76"; then
    echo "BMP280 detected at I2C address 0x77 or 0x76."
else
    echo "Warning: No BMP280 detected on I2C bus. Check wiring or sensor."
fi

echo "Setup complete!"
echo "To run your Python script, activate the virtual environment first:"
echo "  source $VENV_DIR/bin/activate"
echo "Then run: python3 your_script.py"
echo "Note: If DHT11 readings fail, try running with 'sudo python3 your_script.py' inside the virtual environment."
echo "To deactivate the virtual environment after running, type: deactivate"