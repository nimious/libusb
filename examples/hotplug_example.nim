#
#                 io-usb - Nim bindings for libusb, the
#             cross-platform user library to access USB devices.
#                (c) Copyright 2015 Headcrash Industries LLC
#                   https://github.com/nimious/io-usb
#
# libusb provides generic access to USB devices. It is portable, requires no
# special privileges or elevation and supports all versions of the USB protocol.
#
# This file is part of the `Nim I/O` package collection for the Nim programming
# language (http://nimio.us). See the file LICENSE included in this distribution
# for licensing details. Pull requests for fixes or improvements are encouraged.
#

import libusb


## initialize library
let r = libusb_init(nil)

if r < 0:
  echo "Error: Failed to initialize libusb"
else:
  echo "Success: Initialized libusb"






  ## shut down library
  libusb_exit(nil)

echo "Exiting."
