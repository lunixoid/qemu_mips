echo "Start boot script"

test -n "${BOOT_ORDER}" || setenv BOOT_ORDER "A B"
test -n "${BOOT_A_LEFT}" || setenv BOOT_A_LEFT 3
test -n "${BOOT_B_LEFT}" || setenv BOOT_B_LEFT 3

setenv root
for BOOT_SLOT in "${BOOT_ORDER}"; do
  if test "x${root}" != "x"; then
    # skip remaining slots
  elif test "x${BOOT_SLOT}" = "xA"; then
    if test ${BOOT_A_LEFT} -gt 0; then
      echo "Found valid slot A, ${BOOT_A_LEFT} attempts remaining"
      setexpr BOOT_A_LEFT ${BOOT_A_LEFT} - 1
      setenv root "root=/dev/hda2 rauc.slot=A"
    fi
  elif test "x${BOOT_SLOT}" = "xB"; then
    if test ${BOOT_B_LEFT} -gt 0; then
      echo "Found valid slot B, ${BOOT_B_LEFT} attempts remaining"
      setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
      setenv root "root=/dev/hda3 rauc.slot=B"
    fi
  fi
done

if test -n "${root}"; then
  saveenv
else
  echo "No valid slot found, resetting tries to 3"
  setenv BOOT_A_LEFT 3
  setenv BOOT_B_LEFT 3
  saveenv
  reset
fi

fatload ide 0 0x81000000 uImage
setenv bootargs "console=ttyS0,38400n8r loglevel=8 mem=128M@0x0 rmem=128M@0x8000000 mtdparts=physmap-flash.0:128k@3968k(u-boot-env) init=/sbin/init ${root} rootfstype=ext4 rw rootwait"
printenv bootargs
bootm 0x81000000
