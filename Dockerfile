# Use an official Python runtime as a parent image
FROM ruby:2.3.5

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in requirements.txt
RUN bundle install

# Make port 80 available to the world outside this container
EXPOSE 80 9777

# Define environment variable
# ENV NAME World

# Run when the container launches
CMD bundle exec ruby -S rackup -w config.ru --host 0.0.0.0 -p 80
