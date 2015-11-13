## *io-usb* - Nim bindings for libusb, the cross-platform user library to access
## USB devices.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

import libusb, strutils


# The following program is a basic example of using `libusb` to print out the
# list of available USB devices.


proc printDevice(device: ptr LibusbDevice) =
  # Print information about the given USB device
  var desc: LibusbDeviceDescriptor
  let r = libusbGetDeviceDescriptor(device, addr desc)
  if (r < 0):
    echo "Error: Failed to get device descriptor"
  else:
    var p = ""
    var path: array[8, uint8]
    let n = libusbGetPortNumbers(device, addr path[0], (cint)sizeof(path))
    if n > 0:
      p = " path: "
      p.add($path[0])
      for i in 1.. <n:
        p.add(".")
        p.add($path[i])
    echo toHex(desc.idVendor, 4), ":", toHex(desc.idProduct, 4),
      " (bus ", libusbGetBusNumber(device),
      ", device ", libusbGetDeviceAddress(device), ")", p


# initialize library
let r = libusbInit(nil)

if r < 0:
  echo "Error: Failed to initialize libusb"
else:
  echo "Success: Initialized libusb"

  # detect available USB devices
  var devices: ptr LibusbDeviceArray = nil
  let cnt = libusbGetDeviceList(nil, addr devices)
  echo "Number of detected USB devices: ", cnt

  # print device details
  for i in 0..high(devices[]):
    if devices[i] == nil:
      break
    printDevice(devices[i])

  # free list of devices
  libusbFreeDeviceList(devices, 1)

  # shut down library
  libusbExit(nil)

echo "Exiting."
