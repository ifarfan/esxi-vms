mkdir iso
cp user-data.txt iso/user-data.txt
mkisofs -o user-data.iso -r iso
