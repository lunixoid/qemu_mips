# qemu_mips
This project contains extension for buildroot project.
Main purposes:
- Train embedded development technics
- MVP for auto-tests

## Build
### Requirements
- GCC 7.4+
- make
- cpio
- rsync
- bc
- qemu

You can use docker image `buildroot/base` instead.

### Make options
```shell
# Create images
make
# Smoke run
make test
# Play inside of firmware
make qemu_shell
```

## What you can check now
### One little thing about boot process
The project tries to reproduce real hardware (not malta) and run in QEMU. Many hardware vendors use the u-boot as bootloader for their boards.
So in this project we have to use the same way to boot:

u-boot -> Linux Kernel -> Application
### u-boot environment
```shell
# Start qemu
make qemu_shell

# Wait for Linux boot
# Login with root/root credentials

# Print u-boot environment
fw_printenv
# Change and check u-boot environment
fw_setenv test success
reboot

# After u-boot starts you have 2 seconds to interrupt the boot process - just hit ENTER
# Check the environment
> printenv test
test=success
```