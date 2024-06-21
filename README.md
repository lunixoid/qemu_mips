# qemu_mips
This project contains extension for buildroot project.
Main purposes:
- Train embedded development technics
- MVP for auto-tests

## Build
### Requirements
- GCC 7.4 - 9.x
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

# 1. Wait for Linux boot
# 2. Login with root/root credentials
# 3. Print u-boot environment
fw_printenv
# 4. Change and check u-boot environment
fw_setenv test success
reboot
# 5. After u-boot starts you have 2 seconds to interrupt the boot process - just hit ENTER
# 6. Check the environment
> printenv test
test=success
```

### System update
```shell
# 1.   Create update file
make update
# 2.   In separated console create simple http-server (thats how we download the update)
python3 -m http.server -b YOUR_IP
# 3.   Start qemu
make qemu_shell
# 4.   Wait for Linux boot
# 5.   Login with root/root credentials
# 6.   Check current system status
rauc status
# 6.1. Output example
=== System Info ===
Compatible:  qemu_mips
Variant:     
Booted from: rootfs.0 (A)

=== Bootloader ===
Activated: rootfs.0 (A)

=== Slot States ===
o [rootfs.1] (/dev/hda3, ext4, inactive)
        bootname: B
        boot status: good

x [rootfs.0] (/dev/hda2, ext4, booted)
        bootname: A
        boot status: good
# 7.   Install update
rauc -d install http://YOUR_IP:8000/build/rootfs.raucb
reboot
# 8.   Check current system status
rauc status
# 8.1. Output example
=== System Info ===
Compatible:  qemu_mips
Variant:     
Booted from: rootfs.1 (B)

=== Bootloader ===
Activated: rootfs.1 (B)

=== Slot States ===
x [rootfs.1] (/dev/hda3, ext4, booted)
        bootname: B
        boot status: good

o [rootfs.0] (/dev/hda2, ext4, inactive)
        bootname: A
        boot status: good
```
