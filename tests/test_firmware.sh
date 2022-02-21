#!/usr/bin/expect -f

#starts guest vm, run benchmarks, poweroff
set timeout 10

#Start the guest VM
spawn qemu-system-mipsel -cpu 24Kc -M malta -m 1024 -nodefaults -nographic -serial stdio -bios $env(BIOS) -drive file=$env(IMAGE),format=raw -net nic,model=pcnet -net user

#Login process
expect "login: "
#Enter username
send "root\r"

#Enter Password
expect "Password: "
send "root\r"

#poweroff the Guest VM
expect "# "
send "halt\r"