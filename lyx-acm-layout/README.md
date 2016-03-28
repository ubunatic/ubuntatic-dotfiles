Install ACM tepmlates in Lyx
============================
1. Copy sig-alternate.cls and acmtrans2e.cls to <miktex>/text/latex/00custom
2. run sudo texhash (in Windows use miktex: Programs->MiKTeX->Settings and press there "Refresh FNDB")
3. copy files in .lyx/layouts to $HOME/.lyx/layouts (in Windows it should be "Application Data/Lyx2.0/layouts")
4. run LyX->Tools->Reconfigure

~/.lyx/textclass.lst should now contain the following entries:
"acmtrans2e" "acmtrans2e" "article (ACM)" "true" "acmtrans2e.cls"
"sig-alternate" "sig-alternate" "article (ACM SIG Proceedings MINIMAL)" "true" "sig-alternate.cls"

If you are sure that you have added the cls and layout files to the correct dirs
you may manually add/change these entrie in textclass.lst (My Windows LyX sometimes has problems finding the classes. maybe beause I use a portable miktex installed on an USB drive/SD card).

