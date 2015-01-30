## *io-usb* - Nim bindings for libusb, the cross-platform user library to access
## USB devices.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

import libusb


# The following program is a basic example of using `libusb` to print out the
# list of available USB devices.

var devices: ptr LibusbDeviceArray


## initialize library
let r = libusbInit(nil)

if r < 0:
  echo "Error: Failed to initialize libusb"
else:
  echo "Success: Initialized libusb"

  ## detect available USB devices
  let cnt = libusbGetDeviceList(nil, addr devices)
  echo "Number of detected USB devices: ", cnt

  ## print device details
  for i in 0..high(devices[]):
    echo "Details for device #", i
    let device = devices[i]
    if device == nil:
      break

    block:
      echo "  Details:"
      echo "    Bus: ", libusbGetBusNumber(device),
        ", Address: ", libusbGetDeviceAddress(device)
      var path: array[8, uint8]
      let r = libusbGetPortNumbers(device, addr path[0], (cint)sizeof(path))
      if (r > 0):
        var s = "    Path: "
        s.add($path[0])
        for i in 1..(r - 1):
          s.add(".")
          s.add($path[i])
        echo s

    block:
      echo "  Descriptor:"
      var desc: LibusbDeviceDescriptor
      let r = libusbGetDeviceDescriptor(device, addr desc)
      if (r < 0):
        echo "    Error: Failed to get descriptor"
      else:
        echo "    Vendor: ", desc.idVendor
        echo "    Device: ", desc.bcdDevice

  ## free list of devices
  libusbFreeDeviceList(devices, 1)

  ## shut down library
  libusbExit(nil)

echo "Exiting."
