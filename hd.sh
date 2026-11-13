#!/data/data/com.termux/files/usr/bin/bash
# Chamado pelo termux-usb: recebe o descritor USB e corre o heimdall
export TERMUX_USB_FD="${TERMUX_USB_FD:-${@: -1}}"
cd ~/tab
eval heimdall $(cat ~/tab/hd-args) 2>&1 | tee -a ~/tab/heimdall.log
