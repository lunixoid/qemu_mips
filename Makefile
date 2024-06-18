THIRDPARTY_PATH			= $(CURDIR)/thirdparty
BUILDROOT_PATH			= $(THIRDPARTY_PATH)/buildroot

QEMU_BIOS				= $(BUILDROOT_PATH)/output/build/uboot-2021.07/u-boot-swap.bin
QEMU_IMAGE				= $(BUILDROOT_PATH)/output/images/sdcard.img

RAUC					= $(BUILDROOT_PATH)/output/host/bin/rauc
RAUC_ROOTFS				= $(CURDIR)/src/buildroot/rootfs_overlay/etc/rauc
BUILD_DIR				= $(CURDIR)/build
UPDATE_IMAGE			= $(BUILD_DIR)/rootfs.raucb

all: qemu_image

$(QEMU_IMAGE):
	openssl req -x509 -newkey rsa:4096 -nodes -keyout $(RAUC_ROOTFS)/key.pem -out $(RAUC_ROOTFS)/cert.pem -subj "/O=rauc Inc./CN=rauc-demo"
	$(MAKE) -C $(BUILDROOT_PATH) BR2_EXTERNAL=$(CURDIR)/src/buildroot qemu_defconfig
	$(MAKE) -C $(BUILDROOT_PATH) -j$(shell nproc)

$(UPDATE_IMAGE):
	rm -rf $(BUILD_DIR)/install-content
	mkdir -p $(BUILD_DIR)/install-content
	cp $(CURDIR)/src/manifest.raucm $(BUILD_DIR)/install-content
	cp $(BUILDROOT_PATH)/output/images/rootfs.ext4 $(BUILD_DIR)/install-content
	$(RAUC) bundle \
		--key=$(RAUC_ROOTFS)/key.pem \
		--cert=$(RAUC_ROOTFS)/cert.pem \
		$(BUILD_DIR)/install-content \
		$(UPDATE_IMAGE)

.PHONY: all qemu_image qemu_shell update test clean distclean

qemu_image: $(QEMU_IMAGE)
qemu_shell: qemu_image
	qemu-system-mipsel \
		-cpu 24Kc -M malta -m 1024 \
		-nodefaults -nographic -serial stdio \
		-bios $(QEMU_BIOS) \
		-drive file=$(QEMU_IMAGE),format=raw \
		-net nic,model=pcnet,macaddr=52:54:ab:cd:ef:4a -net user

update: $(UPDATE_IMAGE)

test: qemu_image
	BIOS=$(QEMU_BIOS) IMAGE=$(QEMU_IMAGE) $(CURDIR)/tests/test_firmware.sh

clean:
	rm -rf $(BUILD_DIR)
distclean: clean
	$(MAKE) -C $(BUILDROOT_PATH) distclean
