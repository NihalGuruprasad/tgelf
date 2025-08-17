import json
import random
import time
from datetime import datetime

def generate_random_data():
    return {
        "timestamp": datetime.now().isoformat(),
        "number1": random.randint(1, 100),
        "number2": random.uniform(0, 50),
        "number3": random.randint(-50, 50)
    }

def write_to_json(data, filename="random.json"):
    try:
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4)
        print(f"Data written to {filename} at {data['timestamp']}")
    except Exception as e:
        print(f"Error writing to file: {e}")

def main():
    while True:
        random_data = generate_random_data()
        write_to_json(random_data)
        time.sleep(4)

if __name__ == "__main__":
    main()
