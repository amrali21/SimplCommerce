#!/bin/bash
set -e

# Wait until SQL Server is ready
until psql -h postgres-db -U postgres -d mydb -c "SELECT 1" &> /dev/null; do
  echo "Waiting for SQL Server..."
  sleep 5
done

echo "NOW RUN BASH PROCESS"
if psql -h postgres-db --username postgres -lqt | cut -d \| -f 1 | grep -qw simplcommerce; then
    echo "simplcommerce database existed"
else
    echo "create new database simplcommerce"
    {
    psql -h postgres-db --username postgres -c "CREATE DATABASE simplcommerce WITH ENCODING 'UTF8'"
    psql -h postgres-db --username postgres -d simplcommerce -a -f /app/dbscript.sql
    } || {
          echo "db error will skip"
    }
fi

cd /app && dotnet SimplCommerce.WebHost.dll 
