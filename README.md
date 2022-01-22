# Debian Kernel Compilation Guide

based on https://askubuntu.com/questions/1081472/vmlinuz-4-18-12-041812-generic-has-invalid-signature

```bash
apt install cpuinfo build-essential make gcc bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev bison rsync sbsigntool
cd /usr/src/
wget -c https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.16.tar.xz
tar xf linux-5.15.16.tar.xz
rm linux
ln -s linux-5.15.16 linux
cd linux
cp /boot/config-5.15.15 .config
make oldconfig
nice make -j`nproc` bindeb-pkg
```

* After this finishes we need to sign the kernel:

```bash
openssl req -config ./mokconfig.cnf \
        -new -x509 -newkey rsa:2048 \
        -nodes -days 36500 -outform DER \
        -keyout "MOK.priv" \
        -out "MOK.der"
```

* followed by:
```bash
openssl x509 -in MOK.der -inform DER -outform PEM -out MOK.pem
```

* this generates the following files:

```commandline
MOK.der
MOK.pem
MOK.priv
```

then we need to enroll the keys:
```bash
mokutil --import MOK.der
```
* Restart your system. You will encounter a blue screen of a tool called MOKManager. Select "Enroll MOK" and then "View key". Make sure it is your key you created in step 2. Afterwards continue the process and you must enter the password which you provided in step 4. Continue with booting your system.
* Verify your key is enrolled via:
```bash
mokutil --list-enrolled
```

* Then we can sign the freshly compiled kernel:
```bash
./sign.sh /boot/vmlinuz-5.15.15. /boot/vmlinuz-5.15.15.signed
```

* Copy initrd to signed initrd, Update grub and reboot:
```bash
cp /boot/initrd.img-5.15.16 /boot/initrd.img-5.15.16.signed
update-grub &&  reboot
```
