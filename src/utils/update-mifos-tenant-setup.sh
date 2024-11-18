#!/bin/bash

# Default settings
MYSQL_USER="root"
MYSQL_PASSWORD="mysqlpw"
MYSQL_HOST="mysql.infra.svc.cluster.local"
MYSQL_DATABASE="fineract_tenants"
MYSQL_IMAGE="mysql:5.7"
FINERACT_DEFAULT_TENANTDB_MASTER_PASSWORD="fineract"
NAMESPACE="mifosx-1"
CONFIG_FILE=""
SKIP_CONFIRM=0

# Declare tenant storage
TENANTS=() 

# Show usage
usage() {
    cat << EOF
Usage: $0 [options] -f tenant_config_file

Options:
    -u, --mysql-user         MySQL username (default: $MYSQL_USER)
    -p, --mysql-password     MySQL password
    -h, --mysql-host         MySQL host (default: $MYSQL_HOST)
    -d, --mysql-database     MySQL database (default: $MYSQL_DATABASE)
    -i, --mysql-image        MySQL Docker image (default: $MYSQL_IMAGE)
    -n, --namespace          Kubernetes namespace (default: $NAMESPACE)
    -m, --master-password    Fineract master password (default: $FINERACT_DEFAULT_TENANTDB_MASTER_PASSWORD)
    -f, --config-file        Path to tenant configuration file (required)
    -y, --yes                Skip confirmation prompt
    --help                   Show this help message

Tenant Configuration File Format (CSV):
The file should contain one tenant per line in the following format:

tenant_id,tenant_identifier,tenant_name,tenant_timezone,db_host,db_port,db_name,db_user,db_password

Examples:
2,gazelle1,"Tenant for Gazelle",Australia/Adelaide,mysql.host,3306,gazelle1_user,gazelle1_db,gazelle1_pw
3,gazelle2,"Second Tenant",UTC,mysql.host,3306,gazelle2_user,gazelle2_db,gazelle2_pw

- tenant_id: Unique numeric identifier for the tenant
- tenant_identifier: Unique string identifier for the tenant
- tenant_name: Human-readable name of the tenant (quoted if it contains spaces)
- tenant_timezone: Timezone for the tenant (e.g., UTC, Australia/Adelaide)
- db_host: Database host for the tenant's schema
- db_port: Port number for the tenant's database connection
- db_name: Name of the tenant's database/schema
- db_user: Username for connecting to the tenant's database
- db_password: Password for the tenant's database user
EOF
}

validate_tenant_config() {
    local line="$1"
    local id identifier name timezone db_host db_port db_name db_user db_pass
    IFS=',' read -r id identifier name timezone db_host db_port db_name db_user db_pass <<< "$line"

    echo "Validating line: $line"
    echo "Fields: ID=$id, Identifier=$identifier, Name=$name, Timezone=$timezone, Host=$db_host, Port=$db_port, DB=$db_name, User=$db_user, Password=$db_pass"

    # Check required fields
    if [ -z "$id" ]; then
        echo "Error: Missing tenant ID"
        return 1
    elif [ -z "$identifier" ]; then
        echo "Error: Missing tenant identifier"
        return 1
    elif [ -z "$name" ]; then
        echo "Error: Missing tenant name"
        return 1
    elif [ -z "$timezone" ]; then
        echo "Error: Missing timezone"
        return 1
    elif [ -z "$db_host" ]; then
        echo "Error: Missing database host"
        return 1
    elif [ -z "$db_port" ]; then
        echo "Error: Missing database port"
        return 1
    elif [ -z "$db_name" ]; then
        echo "Error: Missing database name"
        return 1
    elif [ -z "$db_user" ]; then
        echo "Error: Missing database user"
        return 1
    elif [ -z "$db_pass" ]; then
        echo "Error: Missing database password"
        return 1
    fi

    return 0
}


TENANTS=() # Use a regular array

read_tenant_configs() {
    local config_file="$1"
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Configuration file not found: $config_file"
        exit 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        echo "Processing line: $line" # Debugging output

        if validate_tenant_config "$line"; then
            TENANTS+=("$line") # Append the line to the array
        else
            exit 1
        fi
    done < "$config_file"

    echo "Total tenants processed: ${#TENANTS[@]}" # Debugging output
}




# Get encrypted passwords
get_encrypted_passwords() {
    local db_password="$1"
    local master_password="$2"

    local fineract_pod
    fineract_pod=$(kubectl get pods -n "$NAMESPACE" --no-headers | grep ^fineract-server | awk '{print $1}' | head -1)

    if [[ -z "$fineract_pod" ]]; then
        echo "Error: No Fineract server pod found in namespace $NAMESPACE"
        exit 1
    fi

    local output
    output=$(kubectl exec -n "$NAMESPACE" "$fineract_pod" -- java -cp @/app/jib-classpath-file \
        org.apache.fineract.infrastructure.core.service.database.DatabasePasswordEncryptor \
        "$master_password" "$db_password")

    # Extract encrypted passwords directly
    local db_password_hash
    local master_password_hash
    db_password_hash=$(echo "$output" | awk -F': ' '/The encrypted password:/ {print $2}')
    master_password_hash=$(echo "$output" | awk -F': ' '/The master password hash is:/ {print $2}')

    # Return hashes in the expected format
    echo "$db_password_hash:$master_password_hash"
}


generate_tenant_sql() {
    local sql_file="/tmp/tenant_setup.sql"
    echo "-- Generated tenant setup SQL" > "$sql_file"

    for tenant in "${TENANTS[@]}"; do
        IFS=',' read -r id identifier name timezone db_host db_port db_name db_user db_pass <<< "$tenant"
        echo "Parsed fields: ID=$id, Identifier=$identifier, Name=$name, Timezone=$timezone, Host=$db_host, Port=$db_port, DB=$db_name, User=$db_user, Password=$db_pass" # Debugging

        local encrypted_passwords
        encrypted_passwords=$(get_encrypted_passwords "$db_pass" "$FINERACT_DEFAULT_TENANTDB_MASTER_PASSWORD")
        local db_password_hash master_password_hash
        IFS=':' read -r db_password_hash master_password_hash <<< "$encrypted_passwords"

        if [[ -z "$db_password_hash" || -z "$master_password_hash" ]]; then
            echo "Error: Failed to generate encrypted passwords for tenant $identifier (ID: $id)"
            exit 1
        fi

        cat << EOF >> "$sql_file"

-- Setup for tenant $identifier (ID: $id)
DELETE FROM tenants WHERE id=$id;
DELETE FROM tenant_server_connections WHERE id=$id;

INSERT INTO tenant_server_connections (id, schema_name, schema_server, schema_server_port, schema_username, schema_password, auto_update, master_password_hash)
VALUES ($id, '$db_name', '$db_host', '$db_port', '$db_user', '$db_password_hash', 1, '$master_password_hash');

INSERT INTO tenants (id, identifier, name, timezone_id, country_id, joined_date, created_date, lastmodified_date, oltp_id, report_id)
VALUES ($id, '$identifier', '$name', '$timezone', NULL, NOW(), NOW(), NOW(), $id, $id);
EOF
    done
}


# Execute SQL
execute_sql() {
    local sql_file="$1"
    kubectl run gazelle-mysql-client --rm -i --image="$MYSQL_IMAGE" --restart=Never -- \
        mysql -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$sql_file" && {
        echo "SQL executed successfully."
    } || {
        echo "SQL execution failed."
        exit 1
    }
}

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--mysql-user) MYSQL_USER="$2"; shift ;;
        -p|--mysql-password) MYSQL_PASSWORD="$2"; shift ;;
        -h|--mysql-host) MYSQL_HOST="$2"; shift ;;
        -d|--mysql-database) MYSQL_DATABASE="$2"; shift ;;
        -i|--mysql-image) MYSQL_IMAGE="$2"; shift ;;
        -n|--namespace) NAMESPACE="$2"; shift ;;
        -m|--master-password) FINERACT_DEFAULT_TENANTDB_MASTER_PASSWORD="$2"; shift ;;
        -f|--config-file) CONFIG_FILE="$2"; shift ;;
        -y|--yes) SKIP_CONFIRM=1 ;;
        --help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

[[ -z "$CONFIG_FILE" ]] && { echo "Error: Configuration file is required."; usage; exit 1; }

# Main execution
read_tenant_configs "$CONFIG_FILE"
generate_tenant_sql

if [[ $SKIP_CONFIRM -eq 1 ]] || read -rp "Proceed with SQL execution? (y/n): " confirm && [[ $confirm =~ ^[Yy]$ ]]; then
    execute_sql "/tmp/tenant_setup.sql"
else
    echo "Operation cancelled."
fi
