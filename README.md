# 🚀 Pi-hole API Control (Disable/Enable via URL)

This project provides a **simple Flask-based API** to enable or disable Pi-hole V6 **via a direct URL**. This is useful for non-technical family members who need to temporarily disable Pi-hole without accessing the admin interface.

## 📌Prerequisites
- **A Debian or Debian-based Linux distribution** (Ubuntu, Raspberry Pi OS, etc.)
- **Python 3.11+** must be installed on the system.
- **Docker:** [optional but recommended for easy deployment](https://docs.docker.com/engine/install/).
  
## 🌟 Features
- **Disable Pi-hole for a specific duration** (e.g., 5 minutes)
- **Re-enable Pi-hole easily**
- **Simple API accessible via a browser or automation tools**
- **Runs in Docker for easy deployment**
- **Compatible with Pi-hole v6**

---

## 🚀 Installation & Setup

### 1️⃣ Download the Files and Configure Your Pi-hole API Credentials
Edit `app.py` and replace:

```python
PIHOLE_URL = "https://YOUR_PIHOLE_IP"
PIHOLE_PASSWORD = "YOUR_PIHOLE_PASSWORD"
```

### 2️⃣ Build & Run the Docker Container

```sh
docker build -t pihole-api .
docker run -d --name pihole-api -p 5000:5000 --restart unless-stopped pihole-api
```

Check if the container is running:

```sh
docker ps | grep pihole-api
```

---

## 🌍 Usage (Disable/Enable via Browser)
Once the Flask server is running, you can disable or enable Pi-hole via a simple URL.

✅ Disable Pi-hole for 5 minutes (300 sec):
```
http://YOUR_SERVER_IP:5000/disable_pihole?time=300
```

✅ Enable Pi-hole:
```
http://YOUR_SERVER_IP:5000/enable_pihole
```

➡️ Replace `YOUR_SERVER_IP` with the IP of the server running the API.

---

## 🔧 Debugging & Troubleshooting

### 🔹 Check Flask API Logs
```sh
docker logs pihole-api
```

### 🔹 "Auth failed" Error?
Ensure you are using the correct Pi-hole password in `app.py`.
Check if API access is enabled in Pi-hole:
1. Open Pi-hole Web GUI (`http://YOUR_PIHOLE_IP/admin`).
2. Go to **Settings → API / Web Interface**.
3. Enable API access if required.

### 🔹 Running in a Different Docker Network?
If Pi-hole is running in a separate Docker network, connect the API container:
```sh
docker network connect pihole_network pihole-api
```
(Replace `pihole_network` with your actual network name.)

---

## 📜 License
This project is open-source and licensed under the MIT License.

---

## 📌 Code Files

### `app.py`
```python
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# Pi-hole API Configuration
PIHOLE_URL = "https://YOUR_PIHOLE_IP"
PIHOLE_PASSWORD = "YOUR_PIHOLE_PASSWORD"

def get_sid():
    """Authenticate with Pi-hole and retrieve a Session ID (SID)."""
    data = {"password": PIHOLE_PASSWORD}
    response = requests.post(f"{PIHOLE_URL}/api/auth", json=data, verify=False)

    if response.status_code != 200:
        return None
    
    sid = response.json().get("session", {}).get("sid")
    return sid

def toggle_pihole(blocking, duration=None):
    """Enable or disable Pi-hole."""
    sid = get_sid()
    if not sid:
        return {"error": "Auth failed"}, 401

    headers = {
        "Content-Type": "application/json",
        "X-FTL-SID": sid
    }
    data = {"blocking": blocking}
    
    if duration:
        data["timer"] = duration

    response = requests.post(f"{PIHOLE_URL}/api/dns/blocking", json=data, headers=headers, verify=False)
    return response.json()

@app.route("/disable_pihole", methods=["GET"])
def disable_pihole():
    """Disable Pi-hole for a specified time."""
    time = request.args.get("time", 300, type=int)  # Default: 300 seconds
    response = toggle_pihole(False, time)
    return jsonify(response)

@app.route("/enable_pihole", methods=["GET"])
def enable_pihole():
    """Enable Pi-hole again."""
    response = toggle_pihole(True)
    return jsonify(response)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

### `Dockerfile`
```dockerfile
# Use a minimal Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy dependency file and install packages
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy all files into the Docker image
COPY . .

# Start the Flask application
CMD ["python", "app.py"]
```

---

### `requirements.txt`
```txt
flask
requests
