mkdir Binaries
cd Binaries
mkdir data
cd ..
robocopy data\Resources\Banners Binaries\data\Resources\Banners
robocopy data\Resources\External Binaries\data\Resources\External
copy data\version.ini binaries\data
cd BuildFiles
makensis IVFixer.nsi
makensis main.nsi
cd ..