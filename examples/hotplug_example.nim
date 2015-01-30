## *io-usb* - Nim bindings for libusb, the cross-platform user library to access
## USB devices.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

import libusb


## initialize library
let r = libusbInit(nil)

if r < 0:
  echo "Error: Failed to initialize libusb"
else:
  echo "Success: Initialized libusb"






  ## shut down library
  libusbExit(nil)

echo "Exiting."
