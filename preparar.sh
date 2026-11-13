#!/data/data/com.termux/files/usr/bin/bash
# Prepara o telemóvel (Termux) para instalar o TWRP no Galaxy Tab S 8.4 (SM-T705)
set -e
REPO=https://raw.githubusercontent.com/pedromelomultibrico-sketch/jarvis-tab-s/main
TWRP=twrp-3.7.0_9-0-klimtlte.img
mkdir -p ~/tab && cd ~/tab
echo ">> 1/4 Pacotes"
yes | pkg update -y
pkg install -y git clang cmake make libusb termux-api curl python
echo ">> 2/4 Heimdall (com ligação USB do Termux)"
rm -rf heimdall-src && git clone --depth 1 https://github.com/Benjamin-Dobell/Heimdall heimdall-src
curl -fsSL "$REPO/patch_heimdall.py" -o patch_heimdall.py
python patch_heimdall.py heimdall-src
mkdir -p heimdall-src/build && cd heimdall-src/build
cmake -DDISABLE_FRONTEND=ON -DCMAKE_BUILD_TYPE=Release \
  -DLIBUSB_INCLUDE_DIR=$PREFIX/include/libusb-1.0 -DLIBUSB_LIBRARY=$PREFIX/lib/libusb-1.0.so ..
make -j4 heimdall
cp bin/heimdall $PREFIX/bin/heimdall && cd ~/tab
echo ">> 3/4 TWRP para klimtlte"
curl -fL -e "https://dl.twrp.me/klimtlte/$TWRP.html" "https://dl.twrp.me/klimtlte/$TWRP" -o twrp.img
ls -la twrp.img
echo ">> 4/4 Script de envio"
curl -fsSL "$REPO/tablet.sh" -o tablet.sh && chmod +x tablet.sh
curl -fsSL "$REPO/hd.sh" -o hd.sh && chmod +x hd.sh
heimdall version || true
echo "PRONTO. Liga o tablet em modo Download e corre: ~/tab/tablet.sh"
