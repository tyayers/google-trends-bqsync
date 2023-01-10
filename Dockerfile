FROM python:3.10-slim-bullseye

# Create app directory
WORKDIR /app

# Install app dependencies
COPY requirements.txt ./

RUN pip3 install -r requirements.txt
# Bundle app source
COPY . /app

EXPOSE 8080
CMD [ "python3", "app.py" ]