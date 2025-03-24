# 1. Use the official DBT image as a base image
FROM xemuliam/dbt:snowflake

# 2. Set the working directory inside the container
WORKDIR /usr/app

# 3. Copy your DBT project files into the container
COPY . /usr/app/

# 4. Install any additional dependencies (if you have a requirements.txt)
#RUN pip install --no-cache-dir -r requirements.txt

# 5. Define the command to run when the container starts (for DBT)
CMD ["dbt", "run"]
