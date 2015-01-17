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


## The following program is a basic example of using `libusb` to print out the
## list of available USB devices.

var devices: ptr libusb_device_array


## initialize library
let r = libusb_init(nil)

if r < 0:
  echo "Error: Failed to initialize libusb"
else:
  echo "Success: Initialized libusb"

  ## detect available USB devices
  let cnt = libusb_get_device_list(nil, addr devices)
  echo "Number of detected USB devices: ", cnt

  ## print device details
  for i in 0..high(devices[]):
    echo "Details for device #", i
    let device = devices[i]
    if device == nil:
      break

    block:
      echo "  Details:"
      echo "    Bus: ", libusb_get_bus_number(device), ", Address: ", libusb_get_device_address(device)
      var path: array[8, uint8]
      let r = libusb_get_port_numbers(device, addr path[0], (cint)sizeof(path))
      if (r > 0):
        var s = "    Path: "
        s.add($path[0])
        for i in 1..(r - 1):
          s.add(".")
          s.add($path[i])
        echo s

    block:
      echo "  Descriptor:"
      var desc: libusb_device_descriptor
      let r = libusb_get_device_descriptor(device, addr desc)
      if (r < 0):
        echo "    Error: Failed to get descriptor"
      else:
        echo "    Vendor: ", desc.idVendor
        echo "    Device: ", desc.bcdDevice

  ## free list of devices
  libusb_free_device_list(devices, 1)

  ## shut down library
  libusb_exit(nil)

echo "Exiting."
