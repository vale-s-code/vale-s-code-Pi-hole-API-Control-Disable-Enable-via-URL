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