cd d
nasm pmpage1.asm -o pmtest.com
cd ..
sudo mount -o loop pm.img /mnt/floppy
sudo rm -f /mnt/floppy/*
sudo cp d/pmtest.com /mnt/floppy/p.com
sudo umount /mnt/floppy
