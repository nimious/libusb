## *io-usb* - Nim bindings for libusb, the cross-platform user library to access
## USB devices.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

import libusb, strutils


var done = 0


proc hotplugCallback(ctx: ptr LibusbContext; device: ptr LibusbDevice;
  event: cint; userData: pointer): cint =
  ## Hotplug callback function
  var desc: LibusbDeviceDescriptor
  let rc = libusbGetDeviceDescriptor(device, addr(desc))
  if rc != (cint)LibusbError.success:
    echo "Warning: Failed to get device descriptor", libusbErrorName(rc)
  elif event == libusbHotplugDeviceArrived:
    echo "Device attached: vendor 0x", toHex(desc.idVendor, 4),
      ", product 0x", toHex(desc.idProduct, 4)
  else:
    echo "Device detached: vendor 0x", toHex(desc.idVendor, 4),
      ", product 0x", toHex(desc.idProduct, 4)
  inc done
  result = 0


## initialize library
let r = libusbInit(nil)

if r < 0:
  echo "Error: Failed to initialize libusb"
else:
  echo "Success: Initialized libusb"

  if libusbHasCapability(LibusbCapability.hasHotplug) == 0:
    echo "Sorry, hotplug is not supported on this platform"
  else:
    var cbHandle: LibusbHotplugCallbackHandle

    # register callbacks
    let result = libusbHotplugRegisterCallback(
      nil, # ctx
      libusbHotplugDeviceArrived or libusbHotplugDeviceLeft,
      LibusbHotplugFlag.noFlags, # flags
      libusbHotplugMatchAny, # vendorId
      libusbHotplugMatchAny, # productId
      libusbHotplugMatchAny, # devClass
      hotplugCallback, # cbFn
      nil, # userData
      addr(cbHandle))

    if result != (cint)LibusbError.success:
      echo "Error: Failed to register hotplug callback"
    else:
      # main loop
      while done < 2:
        let rc = libusbHandleEvents(nil)
        if rc < (cint)LibusbError.success:
          echo "Warning: libusbHandleEvents failed: ", libusbErrorName(rc)

  ## shut down library
  libusbExit(nil)

echo "Exiting."
