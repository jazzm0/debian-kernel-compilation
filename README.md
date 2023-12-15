# Debian Kernel Compilation Guide

based on https://askubuntu.com/questions/1081472/vmlinuz-4-18-12-041812-generic-has-invalid-signature

```bash
apt install cpuinfo build-essential make gcc bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarve bison rsync sbsigntool debhelper
cd /usr/src/
wget -c https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.7.tar.xz
tar xf linux*.xz
rm linux
ln -s linux-6.6.7 linux
cd linux
cp /boot/config-6.6.7 .config
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
<<<<<<< HEAD
./sign.sh /boot/vmlinuz-6.6.7
```

* Update grub and reboot:
```bash
update-grub &&  reboot
```
