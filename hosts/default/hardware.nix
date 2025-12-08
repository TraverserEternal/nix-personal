# Hardware Configuration for default host
# This file contains hardware-specific settings that are typically generated
# by nixos-generate-config. In a real deployment, this would be customized
# based on the actual hardware detected. For now, we provide a basic
# configuration that should work on most modern systems.

{ config, lib, pkgs, modulesPath, ... }:

{
  # Import the generated hardware configuration template
  # This provides basic hardware detection and module loading
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Bootloader configuration
  # We use systemd-boot (formerly gummiboot) for EFI systems as it's
  # simple, reliable, and integrates well with NixOS
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel modules to load at boot
  # These are common modules for most systems; hardware-specific modules
  # will be added based on detected hardware in later phases
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ ];

  # Additional kernel modules for the running system
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Full Disk Encryption with LUKS
  # We implement LUKS encryption on LVM for complete drive security.
  # This provides military-grade encryption (AES-XTS) with PBKDF2/Argon2
  # key derivation functions. The encryption key is stored in the initrd
  # for seamless boot process, requiring password authentication before
  # the initrd loads any encrypted volumes.

  boot.initrd.luks.devices = {
    # Root filesystem encryption
    # The root partition is encrypted with LUKS, requiring a password
    # at boot time. This ensures that even if the drive is physically
    # removed, the data remains inaccessible without the decryption key.
    "root" = {
      device = "/dev/disk/by-uuid/PLACEHOLDER";  # Replace with actual UUID
      preLVM = true;  # Decrypt before LVM activation
      allowDiscards = true;  # Enable TRIM support for SSD performance
    };

    # Home directory encryption (optional additional layer)
    # While the root is encrypted, we can add separate encryption for
    # the home directory for additional security granularity
    # "home" = {
    #   device = "/dev/disk/by-uuid/PLACEHOLDER";
    #   preLVM = true;
    #   allowDiscards = true;
    # };
  };

  # Filesystem configuration
  # With LUKS encryption, the filesystems are configured on top of
  # the decrypted LUKS devices via LVM logical volumes
  fileSystems."/" = {
    device = "/dev/mapper/vg-root";  # LVM logical volume
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];  # SSD optimizations
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/PLACEHOLDER";  # Unencrypted boot partition
    fsType = "vfat";
  };

  # Encrypted swap
  # Swap space is also encrypted to prevent sensitive data leakage
  # to disk when memory is swapped out
  swapDevices = [
    {
      device = "/dev/mapper/vg-swap";
      encrypted = {
        enable = true;
        label = "swap";
        blkDev = "/dev/disk/by-uuid/PLACEHOLDER";  # Physical swap partition
      };
    }
  ];

  # Power management
  # Enable power management features for better battery life and performance
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # Hardware-specific settings
  # Configure hardware based on detected components. In a production setup,
  # these would be automatically detected and configured by the auto-
  # configuration tool. For now, we provide configurations for common hardware.

  # GPU and Graphics Configuration
  # Enable graphics support with drivers for common GPUs
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Required for Steam and some applications

    # Extra packages for graphics acceleration
    extraPackages = with pkgs; [
      vaapiVdpau  # Video acceleration
      libvdpau-va-gl  # VDPAU to VAAPI wrapper
    ];
  };

  # NVIDIA GPU Support (uncomment if using NVIDIA)
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   open = false;  # Use proprietary drivers
  #   nvidiaSettings = true;
  # };

  # AMD GPU Support (uncomment if using AMD)
  # hardware.amdgpu = {
  #   initrd.enable = true;  # Enable early loading
  #   opencl.enable = true;  # OpenCL support for compute tasks
  # };



  # Audio Configuration
  # Basic audio setup; PipeWire will be configured in Phase 4
  hardware.pulseaudio.enable = false;  # Disable PulseAudio in favor of PipeWire
  security.rtkit.enable = true;  # Realtime kit for audio



  # Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;  # Don't enable by default for security
  };

  # Enable firmware for various devices
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # CPU microcode updates
  # This provides security updates for the CPU
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
