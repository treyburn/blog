+++
date = '2025-05-31'
author = "travis reyburn"
title = "repair pop!_os after nvidia-driver-570 update fails"
displayTitle = "rock foundations and paper homes"
subtitle = "the duality of linux"
tagline = "adventures in being a desktop linux operator"
description = "how to repair the linux distro pop!_os after nvidia-driver-570 installation causes black screen"
summary = ""
aliases = []
tags = []
keywords = ["pop!_os", "nvidia-driver-570", "black screen", "linux"]
+++
## a beginner's thoughts on linux

i've been working with linux for just a few short years now.

linux is pretty amazing. it's been around forever[^1], there's a million different distributions of it, and it mostly exists from the hard work of unpaid volunteers. everything from phones, to dishwashers, to drones, to the entirety internet runs on some flavor of it. its low resource usage is sometimes unbelievable compared to windows. the gnu cli tooling, systemd, ebpf, cgroups, io_uring -- the more i learn, the more astounding and thoughtfully engineered it all seems.

and yet -- there's this *jankness* to linux that i cannot shake. specifically desktop linux. the *foundation* of linux -- the kernel -- is this triumph of engineering. yet userland is a hot mess. things that *just work* on crap like windows -- audio, usb devices, graphics drivers, and displays. for whatever reason[^2] linux desktop just feels so immature compared to macos or even -- *shudders* -- windows. 

why do i need to care about glibc and musl?[^3]

## when things go wrong

the other day i tried to update my nvidia graphics driver. it was there in the pop!_shop -- listed under available updates: `nvidia-driver-570`.

it had this seductive little `install` button next to it. how could i not click? why *wouldn't* i want the **latest** and **greatest** driver? i do this *all the time* in windows.

so i did what every doe-eyed, wet-behind-the-ears, fresh-faced linux user does -- i smashed that install button and sat back to bask in my big-brained linux smugness.

and then my screen went black. and it never came back.

## when things go worse

after a moment of panic -- i decided to just walk away. maybe if i go do something else it'll solve itself? nope.

ok -- no worries. i'll just boot into safe-mode and fix whatever went wrong. that'll be easy, right? nope.

safe-mode wasn't even an option. turns out my [janky bootloader config](2025_05_04_my_first_post.md#bootloader-customization) no longer let me set the args i needed to boot in with safe-mode. great.

to be fair -- i did this to myself.

ok -- well no worries, i'll just boot in to the recovery partition, right? lol no. 

more black screen.

ok -- well what about this minimalist busy-box linux vm mentioned deep in the bowels of my bootloader menus?

nice try but whatever native resolution this thing was meant to run on is absolutely incompatible with my 3440x1440 monitor.

so what now?

## claude to the rescue

we go begging to our friend [claude](https://claude.ai).

> hey claude -- I’m running a dual boot of windows and pop os of my machine. I’m using refind as my boot manager. I tried to update a graphics driver on pop os but I messed up and now I cannot boot into pop os. how do I recover from this?

> greetings human -- here are a few options:
>   Option 1: Boot into Recovery Mode
>   Option 2: Use a Live USB
>   Option 3: Boot with Recovery Parameters
>   Option 4: System76 Refresh Tool

> hey claude -- i've tried option 1 and 3. i don't want to try option 4 yet. tell me more about option 3.

> greetings human -- follow these steps and you'll be on your way to publishing a blog nobody will ever read.
>   1. Create a Pop!_OS live USB from another computer. This is what you used to install pop!_os you did keep that, right?
>   2. Boot from the live USB. Don't bother installing -- we just want to use the live os in memory.
>   3. mount your installed Pop!_OS partition
>   4. Chroot into your installation
>   5. Draw the owl --erm -- fix your driver issue

so what did claude tell me to run in order to mount the partition?

```shell
# Identify Your Pop!_OS Partition. 
# Look for a partition labeled as "ext4"; 
# that's likely your Pop!_OS root partition. 
# It might show up as something like: 
# /dev/sda2, /dev/nvme0n1p3, etc.
sudo lsblk -f

# Next, create mount point
sudo mkdir /mnt/popos

# Mount your Pop!_OS root partition 
# (replace sdXY with your actual partition)
sudo mount /dev/sdXY /mnt/popos

# Mount the EFI partition 
# (usually the first small FAT32 partition, around 512MB-1GB)
sudo mount /dev/sdX1 /mnt/popos/boot/efi

# Mount essential directories
sudo mount --bind /dev /mnt/popos/dev
sudo mount --bind /proc /mnt/popos/proc
sudo mount --bind /sys /mnt/popos/sys
sudo mount --bind /run /mnt/popos/run

# Re-enter chroot
sudo chroot /mnt/popos

# Once back in chroot, test:
sudo echo "test"
```

# sudo echo "test"
> test

bingo! we're in.

> ok claude -- i have chroot'd into my partition -- what now?

> greetings human -- now we simply blow away that busted-ass nvidia driver!
```shell
sudo apt remove --purge nvidia-driver-* \
  nvidia-dkms-* \
  nvidia-utils-* \
  libnvidia-*
```

hold my beer -- here we go!

# sudo apt remove --purge nvidia-driver-* ...
> dpkg was interrupted, you must manually run sudp dpkg --configure -a to resolve the problem

> ok claude -- what the heck was that?

> This is actually a good sign -- it means the previous driver installation was interrupted (probably when the system failed to boot), and dpkg just needs to finish what it was doing. Run the following and you'll be on your way.
```shell
# Update package database
sudo apt update

# Fix broken dependencies
sudo apt --fix-broken install

# Clean package cache
sudo apt clean

# Try configure again
sudo dpkg --configure -a
```

so i ran all that and got to `sudo dpkg --configure -a` and got some pretty scary looking console barf with a lot of warnings and errors. 😬

> claude! what's going on?! i'm freaking out, man!

> Excellent! You should be freaking out, man. You are trusting a sensitive computer repair routine to a next-token-prediction model. I don't actually understand any of this linux crap. It's all just matrices and markov chains. It all looks the same; It all bleeds together, man.

> Anyways... this output shows that the dpkg configuration completed successfully! Here's what happened:
> 
> Good News:
>   1. NVIDIA driver 570.133.07 was successfully installed and configured
>   2. DKMS modules built successfully for your kernel (6.12.10-76061203-generic)
>   3. Initramfs was regenerated (update-initramfs: Generating /boot/initrd.img-6.12.10-76061203-generic)
>   4. Bootloader entries were updated (kernelstub copied kernel and initrd to ESP)
> 
> Expected Warnings (not problems):
>   1. AMD GPU firmware warnings are normal -- your system includes those drivers even though you have NVIDIA
>   2. EFI variables error is expected in chroot -- but kernelstub still worked fine
>   3. The systemd service warnings are normal
> 
> Your system should now be bootable! Let's clean up and test. Run these commands next.
```shell
# Update initramfs one more time to be sure
sudo update-initramfs -u -k all

# Update bootloader
sudo bootctl update

# Exit chroot
exit

# Unmount everything
sudo umount -R /mnt/popos

# Reboot to test
sudo reboot
```

so i ran those commands and was back in the bootloader and selected my main pop!_os partition. butt was clenched -- here we go... and there was light!

all was seemingly fixed!

## there and back again
so that's it; claude saved the day -- but also it made more amazed/bewildered by linux. how is it possible that such a recovery process exists -- yet clicking `install` put the system into such a broken state to begin in?

i guess that's the duality of linux. it is robust beyond belief at the core -- and brittle beyond belief on the exterior.

fun fact: at the time of writing this -- a brand new nvidia driver has become available. what could go wrong. 🤡

[^1]: and by that extension -- so have i.
[^2]: money. that reason is money. specifically a major lack of.
[^3]: i mean -- in practice, i really don't. as a user of go, i feel compelled to gripe about the *existence* of dynamic linking at any chance i get.