#!/usr/bin/env bash

# NixOS Hardware Detection Tool
# This script automatically detects hardware and generates hardware-specific
# NixOS configuration. It creates a hardware.nix file with detected CPU, GPU,
# disk partitions, and other hardware settings.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions (output to stderr to avoid polluting stdout)
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

# Function to detect CPU type
detect_cpu() {
    log_info "Detecting CPU architecture..."
    if grep -q "GenuineIntel" /proc/cpuinfo; then
        echo "intel"
    elif grep -q "AuthenticAMD" /proc/cpuinfo; then
        echo "amd"
    else
        echo "unknown"
    fi
}

# Function to detect GPU
detect_gpu() {
    log_info "Detecting GPU..."
    if lspci 2>/dev/null | grep -i nvidia > /dev/null; then
        echo "nvidia"
    elif lspci 2>/dev/null | grep -i amd > /dev/null && lspci 2>/dev/null | grep -i vga | grep -i amd > /dev/null; then
        echo "amd"
    else
        echo "intel"
    fi
}

# Function to detect monitors
detect_monitors() {
    log_info "Detecting monitors..."
    xrandr 2>/dev/null | grep " connected" | awk '{print $1}' || echo "eDP-1"
}

# Function to detect partition UUIDs and encryption type
detect_partition_uuids() {
    # Get all partitions with their UUIDs and types (list format, suppress stderr for clean output)
    local partitions
    if ! partitions=$(lsblk -l -f -o NAME,UUID,FSTYPE 2>/dev/null | grep -E "^[a-zA-Z0-9]"); then
        log_warn "Could not detect partitions - lsblk failed"
        echo "boot_uuid=PLACEHOLDER root_uuid=PLACEHOLDER swap_uuid=PLACEHOLDER encryption_type=unknown"
        return
    fi

    # Initialize variables
    local boot_uuid="" root_uuid="" swap_uuid=""
    local has_luks=false has_plain_root=false has_plain_swap=false

    # Parse partitions to find specific types
    while IFS= read -r line; do
        local name uuid fstype
        name=$(echo "$line" | awk '{print $1}')
        uuid=$(echo "$line" | awk '{print $2}')
        fstype=$(echo "$line" | awk '{print $3}')

        case $fstype in
            vfat)
                if [ -z "$boot_uuid" ]; then
                    boot_uuid="$uuid"
                    log_info "Detected EFI boot partition: $name (UUID: $uuid)"
                fi
                ;;
            crypto_LUKS)
                has_luks=true
                if [ -z "$root_uuid" ]; then
                    root_uuid="$uuid"
                    log_info "Detected LUKS root partition: $name (UUID: $uuid)"
                elif [ -z "$swap_uuid" ]; then
                    swap_uuid="$uuid"
                    log_info "Detected LUKS swap partition: $name (UUID: $uuid)"
                fi
                ;;
            ext4|btrfs|xfs)
                # Assume first ext4/btrfs/xfs partition is root if no LUKS
                if [ -z "$root_uuid" ] && [ "$has_luks" = false ]; then
                    root_uuid="$uuid"
                    has_plain_root=true
                    log_info "Detected plain root partition: $name ($fstype, UUID: $uuid)"
                fi
                ;;
            swap)
                if [ -z "$swap_uuid" ]; then
                    if [ "$has_luks" = false ]; then
                        swap_uuid="$uuid"
                        has_plain_swap=true
                        log_info "Detected plain swap partition: $name (UUID: $uuid)"
                    fi
                fi
                ;;
        esac
    done <<< "$partitions"

    # Determine encryption type
    local encryption_type="unknown"
    if [ "$has_luks" = true ]; then
        encryption_type="luks"
        log_info "System uses LUKS full disk encryption"
    elif [ "$has_plain_root" = true ]; then
        encryption_type="plain"
        log_info "System uses plain filesystems (no encryption detected)"
    else
        log_warn "No recognizable partitions found - using PLACEHOLDER values"
    fi

    # Set defaults if not found
    if [ -z "$boot_uuid" ]; then
        log_warn "EFI boot partition not found - using PLACEHOLDER"
        boot_uuid="PLACEHOLDER"
    fi

    if [ -z "$root_uuid" ]; then
        log_warn "Root partition not found - using PLACEHOLDER"
        root_uuid="PLACEHOLDER"
    fi

    if [ -z "$swap_uuid" ]; then
        log_info "No swap partition found - will use swap file instead"
        swap_uuid="PLACEHOLDER"
    fi

    # Return the UUIDs and encryption type
    echo "boot_uuid=$boot_uuid root_uuid=$root_uuid swap_uuid=$swap_uuid encryption_type=$encryption_type"
}

# Function to generate hardware.nix
generate_hardware_nix() {
    local cpu_type=$1
    local gpu_type=$2
    local boot_uuid=$3
    local root_uuid=$4
    local swap_uuid=$5
    local encryption_type=$6
    local output_dir=$7

    log_info "Generating hardware.nix..."

    cat > "$output_dir/hardware.nix" << EOF
# Hardware Configuration - Auto-generated
# This file was generated by the auto-configuration tool based on detected hardware.
# Encryption type: $encryption_type
# Review and customize the UUIDs and device paths before using.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-$cpu_type" ];
  boot.extraModulePackages = [ ];
EOF

    # Generate filesystem configuration based on encryption type
    if [ "$encryption_type" = "luks" ]; then
        cat >> "$output_dir/hardware.nix" << EOF

  # LUKS Full Disk Encryption
  boot.initrd.luks.devices = {
    "root" = {
      device = "/dev/disk/by-uuid/$root_uuid";
      preLVM = true;
      allowDiscards = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/mapper/vg-root";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/$boot_uuid";
    fsType = "vfat";
  };

EOF

        # Configure swap based on availability
        if [ "$swap_uuid" != "PLACEHOLDER" ] && [ -n "$swap_uuid" ]; then
            cat >> "$output_dir/hardware.nix" << EOF
  swapDevices = [
    {
      device = "/dev/mapper/vg-swap";
      encrypted = {
        enable = true;
        label = "swap";
        blkDev = "/dev/disk/by-uuid/$swap_uuid";
      };
    }
  ];
EOF
        else
            cat >> "$output_dir/hardware.nix" << EOF
  # Swap file configuration (no swap partition detected)
  swapDevices = [
    { device = "/swapfile"; size = 4096; }
  ];
EOF
        fi
EOF
    else
        cat >> "$output_dir/hardware.nix" << EOF

  # Plain filesystem configuration (no encryption)
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/$root_uuid";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/$boot_uuid";
    fsType = "vfat";
  };
EOF

        # Configure swap based on availability
        if [ "$swap_uuid" != "PLACEHOLDER" ] && [ -n "$swap_uuid" ]; then
            cat >> "$output_dir/hardware.nix" << EOF

  swapDevices = [
    { device = "/dev/disk/by-uuid/$swap_uuid"; }
  ];
EOF
        else
            cat >> "$output_dir/hardware.nix" << EOF

  # Swap file configuration (no swap partition detected)
  swapDevices = [
    { device = "/swapfile"; size = 4096; }
  ];
EOF
        fi
    fi

    cat >> "$output_dir/hardware.nix" << EOF

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # Hardware-specific configurations
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
EOF

    # Add GPU-specific configuration
    case $gpu_type in
        nvidia)
            cat >> "$output_dir/hardware.nix" << EOF
    # NVIDIA GPU detected
    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
    };
EOF
            ;;
        amd)
            cat >> "$output_dir/hardware.nix" << EOF
    # AMD GPU detected
    hardware.amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
EOF
            ;;
        *)
            cat >> "$output_dir/hardware.nix" << EOF
    # Intel integrated graphics (handled automatically by hardware.graphics.enable)
EOF
            ;;
    esac

    cat >> "$output_dir/hardware.nix" << EOF
  };

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  hardware.cpu.${cpu_type}.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
EOF
}



# Main function
main() {
    local output_dir="${1:-./modules/generated}"

    log_info "Starting NixOS auto-configuration..."
    log_warn "This tool generates basic configurations. Manual review and customization required!"

    # Check if running as root or with sudo
    if [[ $EUID -eq 0 ]]; then
        log_warn "Running as root. Some detection may not work properly."
    fi

    # Detect hardware
    cpu_type=$(detect_cpu)
    gpu_type=$(detect_gpu)
    monitors=$(detect_monitors)
    uuid_output=$(detect_partition_uuids)

    # Parse UUIDs and encryption type from output
    boot_uuid=$(echo "$uuid_output" | sed 's/.*boot_uuid=\([^ ]*\).*/\1/')
    root_uuid=$(echo "$uuid_output" | sed 's/.*root_uuid=\([^ ]*\).*/\1/')
    swap_uuid=$(echo "$uuid_output" | sed 's/.*swap_uuid=\([^ ]*\).*/\1/')
    encryption_type=$(echo "$uuid_output" | sed 's/.*encryption_type=\([^ ]*\).*/\1/')

    log_info "Detected CPU: $cpu_type"
    log_info "Detected GPU: $gpu_type"
    log_info "Detected monitors: $monitors"
    log_info "Detected UUIDs - Boot: $boot_uuid, Root: $root_uuid, Swap: $swap_uuid"
    log_info "Encryption type: $encryption_type"

    # Create output directory
    mkdir -p "$output_dir"
    log_info "Output directory: $output_dir"

    # Generate hardware configuration
    generate_hardware_nix "$cpu_type" "$gpu_type" "$boot_uuid" "$root_uuid" "$swap_uuid" "$encryption_type" "$output_dir"

    log_success "Hardware configuration generated successfully!"
    log_info "Next steps:"
    echo "  1. Review the generated hardware.nix in $output_dir/"
    echo "  2. If UUIDs show PLACEHOLDER, check partition detection or edit manually"
    echo "  3. Test with: sudo nixos-rebuild build --flake .#default"
    echo "  4. Install with: sudo nixos-rebuild switch --flake .#default"
}

# Run main function with all arguments
main "$@"
