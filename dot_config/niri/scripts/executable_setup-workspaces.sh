#!/bin/bash

# Workspace Setup Script for Niri - v3.0 (YAML-driven)
# Automates opening applications across multiple workspaces and monitors
# Configuration is loaded from screens.yml

# Note: We don't use 'set -e' because some operations like wait_for_window
# can return non-zero without being fatal errors

echo "===========================================
  Niri Workspace Layout Setup Script v3.0
==========================================="
echo ""

# ==================== CONFIGURATION ====================
# Configuration is now loaded from screens.yml
# ======================================================

# Debug mode (can be overridden by YAML config)
DEBUG=true

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    if [ "$DEBUG" = true ]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

# Execute niri command with optional debug output
niri_cmd() {
    log_debug "Executing: niri msg $*"
    niri msg "$@"
}

# Check required tools
check_dependencies() {
    local missing_deps=()
    
    # Check for yq (YAML parser)
    if ! command -v yq &> /dev/null; then
        log_error "yq (YAML parser) not found. Install it with: sudo apt install yq or from https://github.com/mikefarah/yq"
        missing_deps+=("yq")
    fi
    
    # Check for niri
    if ! command -v niri &> /dev/null; then
        log_error "Niri window manager not found"
        missing_deps+=("niri")
    fi
    
    # Check for niri msg (IPC command)
    if ! niri msg version &> /dev/null; then
        log_error "Cannot communicate with Niri (is it running?)"
        missing_deps+=("niri-ipc")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
    
    log_info "Dependencies verified ✓"
}

# Load and validate YAML configuration
load_config() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local config_file="$script_dir/screens.yml"
    
    if [ ! -f "$config_file" ]; then
        log_error "Configuration file not found: $config_file"
        exit 1
    fi
    
    # Validate YAML syntax
    if ! yq '.' "$config_file" &> /dev/null; then
        log_error "Invalid YAML syntax in $config_file"
        exit 1
    fi
    
    log_info "Loaded configuration from $config_file ✓" >&2
    echo "$config_file"
}

# Function to launch application
launch_app() {
    local app_command="$1"
    local app_name="$2"
    
    log_info "Launching $app_name..."
    log_debug "Command: $app_command"
    eval "$app_command" &>/dev/null &
}

# Function to wait for a new window to appear
wait_for_window() {
    local app_name="$1"
    local max_wait="${2:-5}"
    local wait_time=0
    local initial_count=$(niri msg windows 2>/dev/null | wc -l)
    
    log_debug "Waiting for $app_name window to appear (max ${max_wait}s)..."
    
    while [ $wait_time -lt $((max_wait * 2)) ]; do
        sleep 0.5
        wait_time=$((wait_time + 1))
        local current_count=$(niri msg windows 2>/dev/null | wc -l)
        
        if [ $current_count -gt $initial_count ]; then
            log_debug "Window appeared after ${wait_time}x0.5s"
            # Add extra delay to ensure window is fully rendered and placed
            log_debug "Waiting 0.5s for window to fully render..."
            sleep 0.5
            return 0
        fi
    done
    
    log_debug "Window for $app_name didn't appear within ${max_wait}s, but continuing (app may reuse existing window)..."
    # Always return success - some apps reuse windows
    return 0
}

# Main setup function for Niri (YAML-driven)
setup_workspaces() {
    local config_file="$1"
    
    log_info "Starting workspace setup for Niri..."
    
    # Load settings from config
    local debug=$(yq -r '.settings.debug' "$config_file")
    local default_wait=$(yq -r '.settings.default_wait' "$config_file")
    local workspace_switch_wait=$(yq -r '.timing.workspace_switch' "$config_file")
    local window_op_wait=$(yq -r '.timing.window_operation' "$config_file")
    local post_resize_sleep=$(yq -r '.timing.post_resize' "$config_file")
    local monitor_focus_delay=$(yq -r '.timing.monitor_focus' "$config_file")
    local return_to_primary=$(yq -r '.settings.return_to_primary' "$config_file")
    
    # Override DEBUG if set in config
    if [ "$debug" = "true" ]; then
        DEBUG=true
    elif [ "$debug" = "false" ]; then
        DEBUG=false
    fi
    
    # Get monitor count
    local monitor_count=$(yq -r '.monitors | length' "$config_file")
    local first_monitor=""
    
    # Iterate through monitors
    for ((m=0; m<monitor_count; m++)); do
        local monitor_name=$(yq -r ".monitors[$m].name" "$config_file")
        local is_optional=$(yq -r ".monitors[$m].optional // false" "$config_file")
        
        # Store first monitor for returning at end
        if [ $m -eq 0 ]; then
            first_monitor="$monitor_name"
        fi
        
        # Check if optional monitor exists
        if [ "$is_optional" = "true" ]; then
            if ! niri_cmd outputs 2>&1 | grep -q "$monitor_name"; then
                log_warn "Optional monitor '$monitor_name' not found, skipping"
                continue
            fi
        fi
        
        log_info "Setting up monitor: $monitor_name"
        niri_cmd action focus-monitor "$monitor_name"
        sleep "$monitor_focus_delay"
        
        # Get workspace count for this monitor
        local workspace_count=$(yq -r ".monitors[$m].workspaces | length" "$config_file")
        
        # Iterate through workspaces
        for ((w=0; w<workspace_count; w++)); do
            local workspace_id=$(yq -r ".monitors[$m].workspaces[$w].id" "$config_file")
            
            log_info "=== Monitor: $monitor_name, Workspace $workspace_id ==="
            
            # Switch to workspace (skip for first workspace as we're already there)
            if [ $w -gt 0 ]; then
                niri_cmd action focus-workspace "$workspace_id"
                log_debug "Sleeping ${workspace_switch_wait}s for workspace switch..."
                sleep "$workspace_switch_wait"
            fi
            
            # Get window count for this workspace
            local window_count=$(yq -r ".monitors[$m].workspaces[$w].windows | length" "$config_file")
            
            # Iterate through windows
            for ((win=0; win<window_count; win++)); do
                local window_name=$(yq -r ".monitors[$m].workspaces[$w].windows[$win].name" "$config_file")
                local app=$(yq -r ".monitors[$m].workspaces[$w].windows[$win].app" "$config_file")
                local resize=$(yq -r ".monitors[$m].workspaces[$w].windows[$win].resize" "$config_file")
                local wait_time=$(yq -r ".monitors[$m].workspaces[$w].windows[$win].wait // $default_wait" "$config_file")
                
                # Build command with args
                local args_count=$(yq -r ".monitors[$m].workspaces[$w].windows[$win].args | length" "$config_file")
                local full_command="$app"
                
                if [ "$args_count" != "0" ] && [ "$args_count" != "null" ]; then
                    for ((a=0; a<args_count; a++)); do
                        local arg=$(yq -r ".monitors[$m].workspaces[$w].windows[$win].args[$a]" "$config_file")
                        full_command="$full_command $arg"
                    done
                fi
                
                # Launch app
                launch_app "$full_command" "$window_name"
                wait_for_window "$window_name" "$wait_time"
                
                # Resize window
                niri_cmd action set-column-width "$resize"
                sleep "$post_resize_sleep"
            done
        done
    done
    
    # Return to first monitor if configured
    if [ "$return_to_primary" = "true" ] && [ -n "$first_monitor" ]; then
        log_info "Returning to primary monitor: $first_monitor"
        niri_cmd action focus-monitor "$first_monitor"
        sleep "$monitor_focus_delay"
    fi
    
    log_info "Workspace setup complete!"
    log_info "Note: If apps are on wrong workspaces, try increasing wait times in screens.yml"
}

# Main execution
main() {
    check_dependencies
    
    local config_file=$(load_config)
    if [ $? -ne 0 ]; then
        log_error "Failed to load configuration"
        exit 1
    fi
    
    setup_workspaces "$config_file"
    
    echo ""
    log_info "All done! Your Niri workspaces are ready."
}

main "$@"
