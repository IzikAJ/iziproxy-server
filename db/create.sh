source ${BASH_SOURCE[0]%/*}/../.env

createdb -U $DB_USER -h $DB_HOST -p $DB_PORT $DB_NAME
