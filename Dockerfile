# Use official Python base image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy app files
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Run the Python app (update filename if needed)
CMD ["python", "test_sample.py"]
