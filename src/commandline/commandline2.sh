#!/usr/bin/env bash

source "$RUN_DIR/src/configurationManager/config.sh"  
source "$RUN_DIR/src/environmentSetup/environmentSetup.sh"  
source "$RUN_DIR/src/deployer/deployer.sh"  

# Default configuration file path
DEFAULT_CONFIG_FILE="$RUN_DIR/config.ini"

# Function to check for crudini and install if not found
function install_crudini() {
    if ! command -v crudini &> /dev/null; then
        logWithLevel "$INFO" "crudini not found. Attempting to install..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y crudini
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y crudini
        elif command -v yum &> /dev/null; then
            sudo yum install -y crudini
        else
            logWithLevel "$ERROR" "Neither apt-get, dnf, nor yum found. Please install crudini manually."
            exit 1
        fi
        if ! command -v crudini &> /dev/null; then
            logWithLevel "$ERROR" "Failed to install crudini. Exiting."
            exit 1
        fi
        logWithLevel "$INFO" "crudini installed successfully."
    fi
}

# Global variables that will hold the final configuration.
# Initialize with script defaults where applicable.
mode=""
k8s_user=""
apps=""
environment="local"         # Default value as per original script
debug="false"               # Default value as per original script
redeploy="true"             # Default value as per original script
k8s_distro="k3s"            # Default as per original script's main calls
k8s_user_version="1.31"     # Default as per original script's main calls
CONFIG_FILE_PATH="$DEFAULT_CONFIG_FILE" # Default config file path

# Function to load configuration from the INI file using crudini
# This function populates the global configuration variables directly.
function loadConfigFromFile() {
    local config_path="$1"
    logWithLevel "$INFO" "Attempting to load configuration from $config_path using crudini."

    if [ ! -f "$config_path" ]; then
        logWithLevel "$WARNING" "Configuration file not found: $config_path. Proceeding with defaults and command-line arguments."
        return 0 # Exit successfully, as it's optional
    fi

    # Read [general] section
    local config_mode=$(crudini --get "$config_path" general mode 2>/dev/null)
    if [[ -n "$config_mode" ]]; then mode="$config_mode"; fi

    # Read [environment] section
    local config_k8s_user=$(crudini --get "$config_path" environment user 2>/dev/null)
    if [[ -n "$config_k8s_user" ]]; then
        if [[ "$config_k8s_user" == "\$USER" || "$config_k8s_user" == "\$USER" ]]; then # Check for literal $USER or escaped $USER
            k8s_user="$USER"
            logWithLevel "$INFO" "Expanded '$USER' in config to actual username: $k8s_user"
        else
            k8s_user="$config_k8s_user"
        fi
    fi

    # Read app enablement flags and construct the 'apps' variable
    local infra_enabled=$(crudini --get "$config_path" infra enabled 2>/dev/null)
    local mifosx_enabled=$(crudini --get "$config_path" mifosx enabled 2>/dev/null)
    local vnext_enabled=$(crudini --get "$config_path" vnext enabled 2>/dev/null)
    local phee_enabled=$(crudini --get "$config_path" phee enabled 2>/dev/null)

    # Convert to lowercase for consistent checking
    infra_enabled=$(echo "$infra_enabled" | tr '[:upper:]' '[:lower:]')
    mifosx_enabled=$(echo "$mifosx_enabled" | tr '[:upper:]' '[:lower:]')
    vnext_enabled=$(echo "$vnext_enabled" | tr '[:upper:]' '[:lower:]')
    phee_enabled=$(echo "$phee_enabled" | tr '[:upper:]' '[:lower:]')

    # Logic to derive the single 'apps' variable based on enabled flags
    # This will set the global 'apps' variable.
    if [[ "$vnext_enabled" == "true" && "$phee_enabled" == "true" && "$mifosx_enabled" == "true" ]]; then
        apps="all"
        logWithLevel "$INFO" "Config indicates all core apps (vNext, PHEE, MifosX) are enabled, setting apps to 'all'."
    elif [[ "$infra_enabled" == "true" ]]; then
        apps="infra"
        logWithLevel "$INFO" "Config indicates 'infra' is enabled, setting apps to 'infra'."
    elif [[ "$vnext_enabled" == "true" ]]; then
        apps="vnext"
        logWithLevel "$INFO" "Config indicates 'vnext' is enabled, setting apps to 'vnext'."
    elif [[ "$phee_enabled" == "true" ]]; then
        apps="phee"
        logWithLevel "$INFO" "Config indicates 'phee' is enabled, setting apps to 'phee'."
    elif [[ "$mifosx_enabled" == "true" ]]; then
        apps="mifosx"
        logWithLevel "$INFO" "Config indicates 'mifosx' is enabled, setting apps to 'mifosx'."
    else
        # If no specific apps enabled in config, leave 'apps' as its default (or empty to be defaulted by validateInputs)
        # We don't set a default here, validateInputs will handle it if still empty.
        logWithLevel "$INFO" "No specific apps explicitly enabled in config. Will rely on default or command-line."
    fi

    # Log loaded configuration (initial state before command-line override)
    logWithLevel "$INFO" "Configuration loaded from $config_path:"
    logWithLevel "$INFO" "  mode: ${mode:-<not set>}"
    logWithLevel "$INFO" "  k8s_user: ${k8s_user:-<not set>}"
    logWithLevel "$INFO" "  apps: ${apps:-<not set>}"
}


function welcome {
    echo -e "${BLUE}"
    echo -e " ██████   █████  ███████ ███████ ██      ██      ███████ "
    echo -e "██       ██   ██    ███  ██      ██      ██      ██      "
    echo -e "██   ███ ███████   ███   █████   ██      ██      █████   "
    echo -e "██    ██ ██   ██  ███    ██      ██      ██      ██      "
    echo -e " ██████  ██   ██ ███████ ███████ ███████ ███████ ███████ "
    echo -e "${RESET}"
}

function showUsage {
    echo "
USAGE: $0 [-f <config_file_path>] -m [mode] -u [user] -a [apps] -e [environment] -d [true/false]
Example 1 : sudo $0 -m deploy -u \$USER -d true     # install mifos-gazelle with debug mode and user \$USER
Example 2 : sudo $0 -m cleanapps -u \$USER -d true   # delete apps, leave environment with debug mode and user \$USER
Example 3 : sudo $0 -m cleanall -u \$USER          # delete all apps, all Kubernetes artifacts, and server
Example 4 : sudo $0 -m deploy -u \$USER -a phee      # install PHEE only, user \$USER
Example 5 : sudo $0 -m deploy -u \$USER -a all      # install all apps (vNext, PHEE, and MifosX) with user \$USER
Example 6 : sudo $0 -f /opt/my_config.ini          # Use a custom config file

Options:
  -f config_file_path .. Specify an alternative config.ini file path (optional)
  -m mode ................ deploy|cleanapps|cleanall  (required)
  -u user ................ (non root) user that the process will use for execution (required)
  -a apps ................ vnext|phee|mifosx (apps that can be independently deployed) (optional)
  -e environment ......... currently, 'local' is the only value supported and is the default (optional)
  -d debug ............... enable debug mode (true|false) (optional default=false)
  -r redeploy ............ force redeployment of apps (true|false) (optional, default=true)
    -h|H ................... display this message
"
}

function validateInputs {
        if [[ -z "$mode" || -z "$k8s_user" ]]; then
        echo "Error: Required options -m (mode) and -u (user) must be provided."
        showUsage
        exit 1
    fi

    if [[ "$mode" != "deploy" && "$mode" != "cleanapps" && "$mode" != "cleanall" ]]; then
        echo "Error: Invalid mode '$mode'. Must be one of: deploy, cleanapps, cleanall."
        showUsage
        exit 1
    fi

    if [[ "$mode" == "deploy" || "$mode" == "cleanapps" ]]; then
        if [[ -z "$apps" ]]; then
            echo "No specific apps provided with -a flag. Defaulting to 'all'."
            apps="all"
        elif [[ "$apps" != "infra" && "$apps" != "vnext" && "$apps" != "phee" && "$apps" != "mifosx" && "$apps" != "all" ]]; then
            echo "Error: Invalid value for apps. Must be one of: infra, vnext, phee, mifosx, all."
            showUsage
            exit 1
        fi
    fi

    if [[ -n "$debug" && "$debug" != "true" && "$debug" != "false" ]]; then
        echo "Error: Invalid value for debug. Use 'true' or 'false'."
        showUsage
        exit 1
    fi

    if [[ -n "$redeploy" && "$redeploy" != "true" && "$redeploy" != "false" ]]; then
        echo "Error: Invalid value for redeploy. Use 'true' or 'false'."
        showUsage
        exit 1
    fi

    # Set final defaults if they haven't been set by config or command line
    # These are mostly for optional parameters not handled by loadConfigFromFile's direct assignment
    environment="${environment:-local}"
    debug="${debug:-false}"
    redeploy="${redeploy:-true}"

    logWithLevel "$INFO" "Final validated configuration:"
    logWithLevel "$INFO" "  mode: $mode"
    logWithLevel "$INFO" "  k8s_user: $k8s_user"
    logWithLevel "$INFO" "  apps: $apps"
    logWithLevel "$INFO" "  environment: $environment"
    logWithLevel "$INFO" "  debug: $debug"
    logWithLevel "$INFO" "  redeploy: $redeploy"
    logWithLevel "$INFO" "  k8s_distro: $k8s_distro" # Now includes default value
    logWithLevel "$INFO" "  k8s_user_version: $k8s_user_version" # Now includes default value
}


# Function to parse command-line options into an associative array
# Usage: getOptions <associative_array_name> "$@"
function getOptions() {
    local -n options_map=$1 # Use nameref to pass array by reference (Bash 4.3+)
    shift # Shift past the array name argument
    
    OPTIND=1 # Reset getopts index for fresh parsing
    while getopts "m:k:d:a:e:v:u:r:f:hH" OPTION ; do
        case "${OPTION}" in
            f) options_map["config_file_path"]="${OPTARG}" ;;
            m) options_map["mode"]="${OPTARG}" ;;
            k) options_map["k8s_distro"]="${OPTARG}" ;;
            d) options_map["debug"]="${OPTARG}" ;;
            a) options_map["apps"]="${OPTARG}" ;;
            e) options_map["environment"]="${OPTARG}" ;;
            v) options_map["k8s_user_version"]="${OPTARG}" ;;
            u) options_map["k8s_user"]="${OPTARG}" ;;
            r) options_map["redeploy"]="${OPTARG}" ;;
            h|H) showUsage; exit 0 ;;
            *) logWithLevel "$ERROR" "Unknown option: -${OPTION}"; showUsage; exit 1 ;;
        esac
    done
    # No shift needed on positional parameters outside this function, as we passed "$@" to it
}


# this function is called when Ctrl-C is sent
function cleanUp ()
{
    logWithLevel "$RED" "Performing graceful clean up${RESET}"

    # Set mode for cleanup, ensuring it overrides any other mode for this specific exit path
    mode="cleanup"
    logWithLevel "$INFO" "Initiating cleanup process..."
    # Note: k8s_distro and k8s_user_version are hardcoded here,
    # if you want them configurable for cleanup, ensure they are set from config/cmdline.
    envSetupMain "$mode" "k3s" "1.31" "$environment"

    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}

function trapCtrlc {
    echo
    logWithLevel "$RED" "Ctrl-C caught...${RESET}"
    cleanUp
}

# initialise trap to call trap_ctrlc function
# when signal 2 (SIGINT) is received
trap "trapCtrlc" 2

###########################################################################
# MAIN
###########################################################################
function main {
    welcome
    install_crudini # Ensure crudini is available

    # Declare an associative array to store command-line arguments
    declare -A cmd_args_map

    # Parse command-line arguments into cmd_args_map
    getOptions cmd_args_map "$@"

    # Determine the configuration file path: CLI override first, then default
    if [[ -n "${cmd_args_map["config_file_path"]}" ]]; then
        CONFIG_FILE_PATH="${cmd_args_map["config_file_path"]}"
    fi
    logWithLevel "$INFO" "Using config file: $CONFIG_FILE_PATH"

    # Load configuration from the file. This populates global vars (mode, k8s_user, apps, etc.)
    # Note: Default values for environment, debug, redeploy, k8s_distro, k8s_user_version
    # are already set at the top as global variables.
    loadConfigFromFile "$CONFIG_FILE_PATH"

    # Now, merge command-line arguments, giving them precedence over config file values
    # For each variable, if a command-line value exists, use it.
    # Otherwise, the value from loadConfigFromFile (or initial global default) persists.
    if [[ -n "${cmd_args_map["mode"]}" ]]; then mode="${cmd_args_map["mode"]}"; fi
    if [[ -n "${cmd_args_map["k8s_user"]}" ]]; then k8s_user="${cmd_args_map["k8s_user"]}"; fi
    if [[ -n "${cmd_args_map["apps"]}" ]]; then apps="${cmd_args_map["apps"]}"; fi
    if [[ -n "${cmd_args_map["environment"]}" ]]; then environment="${cmd_args_map["environment"]}"; fi
    if [[ -n "${cmd_args_map["debug"]}" ]]; then debug="${cmd_args_map["debug"]}"; fi
    if [[ -n "${cmd_args_map["redeploy"]}" ]]; then redeploy="${cmd_args_map["redeploy"]}"; fi
    if [[ -n "${cmd_args_map["k8s_distro"]}" ]]; then k8s_distro="${cmd_args_map["k8s_distro"]}"; fi
    if [[ -n "${cmd_args_map["k8s_user_version"]}" ]]; then k8s_user_version="${cmd_args_map["k8s_user_version"]}"; fi


    # Validate and set final defaults for all variables
    validateInputs

    # Main execution logic based on the final determined variables
    if [ "$mode" == "deploy" ]; then
        logWithLevel "$YELLOW" "======================================================================================================"
        logWithLevel "$YELLOW" "The deployment made by this script is currently recommended for demo, test and educational purposes "
        logWithLevel "$YELLOW" "======================================================================================================"
        logWithLevel "$RESET"
        # Using variables for k8s_distro and k8s_user_version, now configurable
        envSetupMain "$mode" "$k8s_distro" "$k8s_user_version" "$environment"
        deployApps "$mifosx_instances" "$apps" "$redeploy"
    elif [ "$mode" == "cleanapps" ]; then
        logWithVerboseCheck "$debug" "$INFO" "Cleaning up Mifos Gazelle applications only"
        deleteApps "$mifosx_instances" "$apps"
    elif [ "$mode" == "cleanall" ]; then
        logWithVerboseCheck "$debug" "$INFO" "Cleaning up all traces of Mifos Gazelle "
        deleteApps "$mifosx_instances" "all"
        # Using variables for k8s_distro and k8s_user_version, now configurable
        envSetupMain "$mode" "$k8s_distro" "$k8s_user_version" "$environment"
    else
        showUsage
    fi
}

###########################################################################
# CALL TO MAIN
###########################################################################
main "$@"