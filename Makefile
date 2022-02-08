THIRDPARTY_PATH			= $(CURDIR)/thirdparty
BUILDROOT_PATH			= $(THIRDPARTY_PATH)/buildroot

ARTIFACTS				= $(CURDIR)/artifacts
QEMU_BIOS				= $(BUILDROOT_PATH)/output/build/uboot-2021.07/u-boot-swap.bin
QEMU_IMAGE				= $(BUILDROOT_PATH)/output/images/sdcard.img

all: qemu_image

$(QEMU_IMAGE):
	$(MAKE) -C $(BUILDROOT_PATH) BR2_EXTERNAL=$(CURDIR)/src/buildroot qemu_defconfig
	$(MAKE) -C $(BUILDROOT_PATH) -j$(shell nproc)

.PHONY: all qemu_image qemu_shell test clean distclean

qemu_image: $(QEMU_IMAGE)
qemu_shell: qemu_image
	qemu-system-mipsel \
		-cpu 24Kc -M malta -m 1024 \
		-nodefaults -nographic -serial stdio \
		-bios $(QEMU_BIOS) \
		-drive file=$(QEMU_IMAGE),format=raw \
		-net nic,model=pcnet -net user

test: qemu_image
	BIOS=$(QEMU_BIOS) IMAGE=$(QEMU_IMAGE) $(CURDIR)/tests/test_firmware.sh

clean:
	rm -rf $(ARTIFACTS)
distclean: clean
	$(MAKE) -C $(BUILDROOT_PATH) clean