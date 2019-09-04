## *libusb* - Nim bindings for libusb, the cross-platform user library to access
## USB devices.
##
## This file is part of the `Nim I/O <http://nimio.us>`_ package collection.
## See the file LICENSE included in this distribution for licensing details.
## GitHub pull requests are encouraged. (c) 2015 Headcrash Industries LLC.

import endians

when defined(linux):
  const dllname = "libusb(|-1.0).so(|.4|.4.4.4)"
elif defined(freebsd):
  const dllname = "libusb.so"
elif defined(macosx):
  const dllname = "libusb.dylib"
elif defined(windows):
  const dllname = "libusb-1.0.dll"
else:
  {.error: "libusb does not support this platform".}


type
  LibusbTimeval* = object
    ## Specifies a time interval.
    tvSec*: clong
    tvUsec*: clong


const
  libusbApiVersion* = 0x01000103  # libusb API version


proc libusbCpuToLe16*(x: uint16): uint16 {.inline.} =
  ## Convert a 16-bit value from host-endian to little-endian format.
  ##
  ## x
  ##   The value to convert
  ## result
  ##   The converted value
  result = 0
  var tmp = x
  littleEndian16(addr result, addr tmp)


template libusbLe16ToCpu*(x: uint16): uint16 =
  ## Convert a 16-bit value from little-endian to host-endian format.
  ##
  ## x
  ##   The value to convert
  ## result
  ##   The converted value
  libusbCpuToLe16(x)


type
  LibusbClassCode* {.pure.} = enum
    ## Enumerates USB device class codes.
    perInterface = 0,
      ## each interface has its own class
    audio = 1,
      ## Audio class
    comm = 2,
      ## Communications class
    hid = 3,
      ## Human Interface Device class
    physical = 5,
      ## Physical
    image = 6,
      ## Image class
    printer = 7,
      ## Printer class
    storage = 8,
      ## Image class
    hub = 9,
      ## Hub class
    data = 10,
      ## Data class
    smartCard = 0x0B,
      ## Smart Card
    contentSecurity = 0x0D,
      ## Content Security
    video = 0x0E,
      ## Video
    healthcare = 0x0F,
      ## Personal Healthcare
    device = 0xDC,
      ## Diagnostic Device
    wireless = 0xE0,
      ## Wireless class
    application = 0xFE,
      ## Application class
    vendorSpec = 0xFF
      ## Class is vendor-specific

  LibusbDescriptorType* {.pure, size: sizeof(uint8).} = enum
    ## Enumerates device descriptor types.
    device = 0x01,
      ## Device descriptor
      ## (see `LibusbDeviceDescriptor <#LibusbDeviceDescriptor>`_)
    config = 0x02,
      ## Configuration descriptor
      ## (see `LibusbConfigDescriptor <#LibusbConfigDescriptor>`_)
    str = 0x03,
      ## String descriptor
    interf = 0x04,
      ## Interface descriptor
      ## (see `LibusbInterfaceDescriptor <#LibusbInterfaceDescriptor>`_)
    endpoint = 0x05,
      ## Endpoint descriptor
      ## (see `LibusbEndpointDescriptor <#LibusbEndpointDescriptor>`_)
    bos = 0x0F,
      ## BOS descriptor
    deviceCapability = 0x10,
      ## Device capability descriptor
    hid = 0x21,
      ## HID descriptor
    report = 0x22,
      ## HID report descriptor
    physical = 0x23,
      ## Physical descriptor
    hub = 0x29,
      ## Hub descriptor
    superspeedHub = 0x2A,
      ## SuperSpeed Hub descriptor
    sSEndpointCompanion = 0x30
      ## SuperSpeed Endpoint Companion descriptor


const
  # Descriptor sizes per descriptor type
  libusbDtDeviceSize* = 18
  libusbDtConfigSize* = 9
  libusbDtInterfaceSize* = 9
  libusbDtEndpointSize* = 7
  libusbDtEndpointAudioSize* = 9
  libusbDtHubNonvarSize* = 7
  libusbDtSsEndpointCompanionSize* = 6
  libusbDtBosSize* = 5
  libusbDtDeviceCapabilitySize* = 3


  # BOS descriptor sizes
  libusbBtUsb20ExtensionSize* = 7
  libusbBtSsUsbDeviceCapabilitySize* = 10
  libusbBtContainerIdSize* = 20


  # We unwrap the BOS => define its max size
  libusbDtBosMaxSize* = ((libusbDtBosSize) +
    (libusbBtUsb20ExtensionSize) +
    (libusbBtSsUsbDeviceCapabilitySize) +
    (libusbBtContainerIdSize))
  libusbEndpointAddressMask* = 0x0000000F
  libusbEndpointDirMask* = 0x00000080


type
  LibusbEndpointDirection* {.pure.} = enum
    ## Enumerates available endpoint directions (used in bit 7 of
    ## `LibusbEndpointDescriptor.endpointAddress <#LibusbEndpointDescriptor>`_
    ## and bit 7 of `LibusbControlSetup.bmRequestType <#LibusbControlSetup>`_)
    hostToDevice = 0x00000000,
      ## In: device-to-host
    deviceToHost = 0x00000080
      ## Out: host-to-device


const
  libusbTransferTypeMask* = 0x00000003
    ## Used in
    ## `LibusbEndpointDescriptor.bmAttributes <#LibusbEndpointDescriptor>`_


type
  LibusbTransferType* {.pure.} = enum
    ## Enumerates endpoint transfer types.
    control = 0,
      ## Control endpoint
    isochronous = 1,
      ## Isochronous endpoint
    bulk = 2,
      ## Bulk endpoint
    interrupt = 3,
      ## Interrupt endpoint
    bulkStream = 4
      ## Stream endpoint


  LibusbStandardRequest* {.pure.} = enum
    ## Enumerates standard requests as defined in table 9-5 of the USB 3.0 spec.
    getStatus = 0x00000000,
      ## Request status of the specific recipient
    clearFeature = 0x00000001,
      ## Clear or disable a specific feature
    reserved2 = 0x00000002,
      ## Reserved for future use
    setFeature = 0x00000003,
      ## Set or enable a specific feature
    reserved4 = 0x00000004
      ## Reserved for future use
    setAddress = 0x00000005,
      ## Set device address for all future accesses
    getDescriptor = 0x00000006,
      ## Get the specified descriptor
    setDescriptor = 0x00000007,
      ## Used to update existing descriptors or add new descriptors
    getConfiguration = 0x00000008,
      ## Get the current device configuration value
    setConfiguration = 0x00000009,
      ## Set device configuration
    getInterface = 0x0000000A,
      ## Return the selected alternate setting for the specified interface
    setInterface = 0x0000000B,
      ## Select an alternate interface for the specified interface
    synchFrame = 0x0000000C,
      ## Set then report an endpoint's synchronization frame
    setSel = 0x00000030,
      ## Sets both the U1 and U2 Exit Latency
    isochDelay = 0x00000031
      ## Delay from the time a host transmits a packet to the time it is
      ## received by the device


  LibusbRequestType* {.pure.} = enum
    ## Enumerates standard requests, as defined in table 9-5 of the USB 3.0
    ## spec. Used in bits 5:6 of
    ## `LibusbControlSetup.bmRequestType <#LibusbControlSetup>`_
    standard = (0x00000000 shl 5),
      ## Standard
    class = (0x00000001 shl 5),
      ## Class
    vendor = (0x00000002 shl 5),
      ## Vendor
    reserved = (0x00000003 shl 5)
      ## Reserved


  LibusbRequestRecipient* {.pure.} = enum
    ## Enumerates recipient bits in the `LibusbControlSetup.bmRequestType`
    ## field. Values 4 through 31 are reserved.
    device = 0x00000000,
      ## Device
    interf = 0x00000001,
      ## Interface
    endpoint = 0x00000002,
      ## Endpoint
    other = 0x00000003
      ## Other recipient

const
  libusbIsoSyncTypeMask* = 0x0000000C


type
  LibusbIsoSyncType* {.pure.} = enum
    ## Enumerates synchronization types for isochronous endpoints.
    none = 0,
      ## No synchronization
    async = 1,
      ## Asynchronous
    adaptive = 2,
      ## Adaptive
    sync = 3
      ## Synchronous

const
  libusbIsoUsageTypeMask* = 0x00000030


type
  LibusbIsoUsageType* {.pure.} = enum
    ## Enumerates usage types for isochronous endpoints.
    data = 0,
      ## Data endpoint
    feedback = 1,
      ## Feedback endpoint
    implicit = 2
      ## Implicit feedback Data endpoint


type
  LibusbDeviceDescriptor* = object
    ## Standard USB device descriptor. This descriptor is documented in section
    ## 9.6.1 of the USB 3.0 specification. All multiple-byte fields are
    ## represented in host-endian format.
    length*: uint8
      ## Size of this descriptor (in bytes)
    descriptorType*: LibusbDescriptorType
      ## Descriptor type (set to `LibusbDescriptorType.device`).
    bcdUSB*: uint16
      ## USB specification release number in binary-coded decimal.
      ## 0x0200 indicates USB 2.0, 0x0110 indicates USB 1.1, etc.
    deviceClass*: uint8
      ## USB-IF class code for the device
      ## (see `LibusbClassCode <#LibusbClassCode>`_)
    deviceSubClass*: uint8
      ## USB-IF subclass code for the device, qualified by `deviceClass` value.
    deviceProtocol*: uint8
      ## USB-IF protocol code for the device, qualified by the deviceClass and
      ## deviceSubClass values.
    maxPacketSize0*: uint8
      ## Maximum packet size for endpoint 0
    idVendor*: cshort
      ## USB-IF vendor ID
    idProduct*: cshort
      ## USB-IF product ID
    bcdDevice*: uint16
      ## Device release number in binary-coded decimal
    iManufacturer*: uint8
      ## Index of string descriptor describing manufacturer
    iProduct*: uint8
      ## Index of string descriptor describing product
    iSerialNumber*: uint8
      ## Index of string descriptor containing device serial number
    numConfigurations*: uint8
      ## Number of possible configurations


  LibusbEndpointDescriptor* = object
    ## Standard USB endpoint descriptor. This descriptor is documented in
    ## section 9.6.6 of the USB 3.0 specification. All multiple-byte fields are
    ## represented in host-endian format.
    length*: uint8
      ## Size of this descriptor (in bytes)
    descriptorType*: LibusbDescriptorType
      ## Descriptor type (set to `LibusbDescriptorType.endpoint`)
    endpointAddress*: uint8
      ## The address of the endpoint described by this descriptor. Bits 0:3 are
      ## the endpoint number. Bits 4:6 are reserved. Bit 7 indicates direction,
      ## see `LibusbEndpointDirection <#LibusbEndpointDirection>`_
    bmAttributes*: uint8
      ## Attributes which apply to the endpoint when it is configured using the
      ## `configurationValue <#LibusbConfigDescriptor`_. Bits 0:1 determine the
      ## transfer type and correspond to
      ## `LibusbTransferType <#LibusbTransferType>`_. Bits 2:3 are only used for
      ## isochronous endpoints and correspond to
      ## `LibusbIsoSyncType <#LibusbIsoSyncType>`_. Bits 4:5 are also only used
      ## for isochronous endpoints and correspond to
      ## `LibusbIsoUsageType <#LibusbIsoUsageType>`_. Bits 6:7 are reserved.
    maxPacketSize*: uint16
      ## Maximum packet size this endpoint is capable of sending/receiving
    interval*: uint8
      ## Interval for polling endpoint for data transfers.
    refresh*: uint8
      ## For audio devices only: the rate at which synchronization feedback is
      ## provided
    synchAddress*: uint8
      ## For audio devices only: the address if the synch endpoint
    extra*: cstring
      ## Extra descriptors. If libusb encounters unknown endpoint descriptors,
      ## it will store them here, should you wish to parse them
    extraLength*: cint
      ## Length of the extra descriptors, in bytes


  LibusbInterfaceDescriptor* = object
    ## A structure representing the standard USB interface descriptor. This
    ## descriptor is documented in section 9.6.5 of the USB 3.0 specification.
    ## All multiple-byte fields are represented in host-endian format.
    length*: uint8
      ## Size of this descriptor (in bytes)
    descriptorType*: LibusbDescriptorType
      ## Descriptor type (set to `LibusbDescriptorType.interface`)
    interfaceNumber*: uint8
      ## Number of this interface
    alternateSetting*: uint8
      ## Value used to select this alternate setting for this interface
    numEndpoints*: uint8
      ## Number of endpoints used by this interface (excluding the control
      ## endpoint)
    interfaceClass*: uint8
      ## USB-IF class code for this interface
      ## (see `LibusbClassCode <#LibusbClassCode>`_)
    interfaceSubClass*: uint8
      ## USB-IF subclass code for this interface, qualified by the
      ## ``interfaceClass`` value
    interfaceProtocol*: uint8
      ## USB-IF protocol code for this interface, qualified by the
      ## ``interfaceClass`` and ``interfaceSubClass`` values
    iInterface*: uint8
      ## Index of string descriptor describing this interface
    endpoint*: ptr LibusbEndpointDescriptor
      ## Array of endpoint descriptors. This length of this array is determined
      ## by the ``numEndpoints`` field
    extra*: cstring
      ## Extra descriptors. If libusb encounters unknown interface descriptors,
      ## it will store them here, should you wish to parse them.
    extraLength*: cint
      ## Length of the extra descriptors, in bytes


  LibusbInterface* = object
    ## Collection of alternate settings for a particular USB interface.
    altsetting*: ptr LibusbInterfaceDescriptor
      ## Array of interface descriptors. The length of this array is determined
      ## by the ``numAltsetting`` field.
    numAltsetting*: cint
      ## The number of alternate settings that belong to this interface


  LibusbConfigDescriptor* = object
    ## A structure representing the standard USB configuration descriptor. This
    ## descriptor is documented in section 9.6.3 of the USB 3.0 specification.
    ## All multiple-byte fields are represented in host-endian format.
    length*: uint8
      ## Size of this descriptor (in bytes)
    descriptorType*: LibusbDescriptorType
      ## Descriptor type (set to `LibusbDescriptorType.config`)
    totalLength*: uint16
      ## Total length of data returned for this configuration
    numInterfaces*: uint8
      ## Number of interfaces supported by this configuration
    configurationValue*: uint8
      ## Identifier value for this configuration
    iConfiguration*: uint8
      ## Index of string descriptor describing this configuration
    bmAttributes*: uint8
      ## Configuration characteristics
    maxPower*: uint8
      ## Maximum power consumption of the USB device from this bus in this
      ## configuration when the device is fully opreation. Expressed in units of
      ## 2 mA.
    interfaces*: ptr LibusbInterface
      ## Array of interfaces supported by this configuration. The length of this
      ## array is determined by the ``numInterfaces`` field.
    extra*: cstring
      ## Extra descriptors. If libusb encounters unknown configuration
      ## descriptors, it will store them here, should you wish to parse them.
    extraLength*: cint
      ## Length of the extra descriptors, in bytes


  LibusbSsEndpointCompanionDescriptor* = object
    ## A structure representing the superspeed endpoint companion descriptor.
    ## This descriptor is documented in section 9.6.7 of the USB 3.0
    ## specification. All multiple-byte fields are represented in host-endian
    ## format.
    length*: uint8
      ## Size of this descriptor
    descriptorType*: LibusbDescriptorType
      ## Descriptor type (set to `LibusbDescriptorType.endpointCompanion`)
    maxBurst*: uint8
      ## The maximum number of packets the endpoint can send or recieve as part
      ## of a burst
    bmAttributes*: uint8
      ## In bulk EP: bits 4:0 represents the maximum number of streams the EP
      ## supports. In isochronous EP: bits 1:0 represents the Mult - a zero
      ## based value that determines the maximum number of packets within a
      ## service interval.
    bytesPerInterval*: uint16
      ## The total number of bytes this EP will transfer every service interval.
      ## valid only for periodic EPs.


  LibusbBosDevCapabilityDescriptor* = object
    ## Generic representation of a BOS Device Capability descriptor. It is
    ## advised to check `devCapabilityType` and call the matching
    ## `libusbGetXXXDescriptor` function to get a structure fully matching
    ## the type.
    length*: uint8
      ## Size of this descriptor (in bytes)
    descriptorType*: LibusbDescriptorType
      ## Descriptor type (set to `LibusbDescriptorType.device`)
    devCapabilityType*: uint8
      ## Device Capability type
    devCapabilityData*: array[0, uint8]
      ## Device Capability data (`length` - 3 bytes)


  LibusbBosDescriptor* = object
    ## Binary Device Object Store (BOS) descriptor. This descriptor is
    ## documented in section 9.6.2 of the USB 3.0 specification.
    ## All multiple-byte fields are represented in host-endian format.
    length*: uint8
      ## Size of this descriptor (in bytes)
    descriptorType*: LibusbDescriptorType
      ## Descriptor type (set to `LibusbDescriptorType.bos`)
    totalLength*: uint16
      ## Length of this descriptor and all of its sub descriptors
    numDeviceCaps*: uint8
      ## The number of separate device capability descriptors in the BOS
    devCapability*: array[0, ptr LibusbBosDevCapabilityDescriptor]
      ## `bNumDeviceCap` Device Capability Descriptors


  LibusbUsb20ExtensionDescriptor* = object
    ## USB 2.0 Extension descriptor. This descriptor is documented in section
    ## 9.6.2.1 of the USB 3.0 specification. All multiple-byte fields are
    ## represented in host-endian format.
    length*: uint8
      ## Size of this descriptor (in bytes)
    descriptorType*: LibusbDescriptorType
      ## Descriptor type (set to `LibusbDescriptorType.deviceCapability`)
    devCapabilityType*: uint8
      ## Capability type (`libusbBtUsb20Extension <#libusbBtUsb20Extension>`_)
    bmAttributes*: uint32
      ## Bitmap encoding of supported device level features. A value of one in a
      ## bit location indicates a feature is supported; a value of zero
      ## indicates it is not supported. See
      ## `LibusbUsb20ExtensionAttributes <#LibusbUsb20ExtensionAttributes>`_.


  LibusbSsUsbDeviceCapabilityDescriptor* = object
    ## Container ID descriptor. This descriptor is documented in section 9.6.2.3
    ## of the USB 3.0 specification. All multiple-byte fields, except UUIDs, are
    ## represented in host-endian format.
    length*: uint8
      ## Size of this descriptor (in bytes)
    descriptorType*: LibusbDescriptorType
      ## Descriptor type (set to `LibusbDescriptorType.deviceCapability`)
    devCapabilityType*: uint8
      ## Capability type
      ## (`libusbBtSsUsbDeviceCapability <#libusbBtSsUsbDeviceCapability>`_)
    bmAttributes*: uint8 ## Bitmap encoding of supported device level features.
      ## A value of one in a bit location indicates a feature is supported; a
      ## value of zero indicates it is not supported. See
      ## `LibusbSsUsbDeviceCapabilityAttributes <#LibusbSsUsbDeviceCapabilityAttributes>`_.
    speedSupported*: uint16
      ## Bitmap encoding of the speed supported by this device when operating in
      ## SuperSpeed mode. See `LibusbSupportedSpeed <#LibusbSupportedSpeed>`_.
    functionalitySupport*: uint8
      ## The lowest speed at which all the functionality supported by the device
      ## is available to the user. For example if the device supports all its
      ## functionality when connected at full speed and above then it sets this
      ## value to 1.
    u1DevExitLat*: uint8
      ## U1 Device Exit Latency
    u2DevExitLat*: uint16
      ## U2 Device Exit Latency


  LibusbContainerIdDescriptor* = object
    ## A structure representing the Container ID descriptor. This descriptor is
    ## documented in section 9.6.2.3 of the USB 3.0 specification. All
    ## multiple-byte fields, except UUIDs, are represented in host-endian
    ## format.
    length*: uint8
      ## Size of this descriptor (in bytes)
    descriptorType*: LibusbDescriptorType
      ## Descriptor type (set to `LibusbDescriptorType.deviceCapability`)
    devCapabilityType*: uint8
      ## Capability type (set to `LibusbBosType.containerId`)
    reserved*: uint8
      ## Reserved for future use
    containerID*: array[16, uint8]
      ## 128 bit UUID


  LibusbControlSetup* = object
    ## Setup packet for control transfers.
    bmRequestType*: uint8
      ## Request type. Bits 0:4 determine recipient, see
      ## `LibusbRequestRecipient`. Bits 5:6 determine type, see
      ## `LibusbRequestType`. Bit 7 determines data transfer direction, see
      ## `LibusbEndpointDirection <#LibusbEndpointDirection>`_.
    request*: uint8
      ## Request. If the type bits of `bmRequestType` are equal to
      ## `LibusbRequestType.standard <#LibusbRequestType>`_ then this field
      ## refers to `LibusbStandardRequest`. For other cases, use of this field
      ## is application-specific.
    value*: uint16
      ## Value. Varies according to request
    index*: uint16
      ## Index. Varies according to request, typically used to pass an index or
      ## offset
    length*: uint16
      ## Number of bytes to transfer


type
  LibusbVersion* = object
    ## Provides the version of the libusb runtime.
    major*: uint16
      ## Library major version
    minor*: uint16
      ## Library minor version
    micro*: uint16
      ## Library micro version
    nano*: uint16
      ## Library nano version
    rc*: cstring
      ## Library release candidate suffix string, e.g. "-rc4"
    describe*: cstring
      ## For ABI compatibility only


  LibusbContext* = object
    ## Structure representing a libusb session. The concept of individual libusb
    ## sessions allows for your program to use two libraries (or dynamically
    ## load two modules) which both independently use libusb. This will prevent
    ## interference between the individual libusb users - for example
    ## `libusbSetDebug <#libusbSetDebug>`_ will not affect the other user of the
    ## library, and `libusbExit <#libusbExit>`_ will not destroy resources that
    ## the other user is still using.
    ##
    ## Sessions are created by `libusbInit <#libusbInit>`_ and destroyed through
    ## `libusbExit <#libusbExit>`_. If your application is guaranteed to only
    ## ever include a single libusb user (i.e. you), you do not have to worry
    ## about contexts: pass ``nil`` in every function call where a context is
    ## required. The default context will be used.


  LibusbDevice* = object
    ## Structure representing a USB device detected on the system. This is an
    ## opaque type for which you are only ever provided with a pointer, usually
    ## originating from `libusbGetDeviceList()`.
    ##
    ## Certain operations can be performed on a device, but in order to do any
    ## I/O you will have to first obtain a device handle using
    ## `libusbOpen <#libusbOpen>`_.
    ##
    ## Devices are reference counted with `libusbRefDevice()` and
    ## `libusbUnrefDevice <#libusbUnrefDevice>`_, and are freed when the
    ## reference count reaches ``0``. New devices presented by
    ## `libusbGetDeviceList <#libusbGetDeviceList>`_ have a reference count of
    ## ``1``, and `libusbFreeDeviceList <#libusbFreeDeviceList>`_ can optionally
    ## decrease the reference count on all devices in the list.
    ## `libusbOpen <#libusbOpen>`_ adds another reference which is later
    ## destroyed by `libusbClose <#libusbClose>`_.

  LibusbDeviceArray* = UncheckedArray[ptr LibusbDevice]
    ## Unchecked array of pointers to USB devices.


  LibusbDeviceHandle* = object
    ## Represents USB device handle. This is an opaque type for which you are
    ## only ever provided with a pointer, usually originating from
    ## `libusbOpen()`. A device handle is used to perform I/O and other
    ## operations. When finished with a device handle, you should call
    ## `libusbClose <#libusbClose>`_.


type
  LibusbSpeed* {.pure.} = enum
    ## Enumerates speed codes to indicate the speed of devices.
    unknown = 0,
      ## The OS doesn't report or know the device speed
    lowSpeed = 1,
      ## The device is operating at low speed (1.5MBit/s)
    fullSpeed = 2,
      ## The device is operating at full speed (12MBit/s)
    highSpeed = 3,
      ## The device is operating at high speed (480MBit/s)
    superSpeed = 4
      ##The device is operating at super speed (5000MBit/s)


  LibusbSupportedSpeed* {.pure.} = enum
    ## Enumerates supported speeds in the ``speedSupported`` bit field.
    lowSpeed = 1,
      ## Low speed operation supported (1.5MBit/s)
    fullSpeed = 2,
      ## Full speed operation supported (12MBit/s)
    highSpeed = 4,
      ## High speed operation supported (480MBit/s)
    superSpeed = 8
      ## Superspeed operation supported (5000MBit/s)


  LibusbUsb20ExtensionAttributes* {.pure.} = enum
    ## Masks for the bits of the `bmAttributes` field in
    ## `LibusbUsb20ExtensionDescriptor <#LibusbUsb20ExtensionDescriptor>`_.
    linkPowerMngmt = 2
      ## Supports Link Power Management (LPM)


  LibusbSsUsbDeviceCapabilityAttributes* {.pure.} = enum
    ## Masks for the bits of the `bmAttributes` field in
    ## `LibusbSsUsbDeviceCapabilityDescriptor <#LibusbSsUsbDeviceCapabilityDescriptor>`_.
    latencyToleranceMsg = 2
      ## Supports Latency Tolerance Messages (LTM)


  LibusbBosType* {.pure.} = enum
    ## Enumerates USB capability types.
    wirelessUsbDeviceCapability = 1,
      ## Wireless USB device capability
    usb20Extension = 2,
      ## USB 2.0 extensions.
    ssUsbDeviceCapability = 3,
      ## SuperSpeed USB device capability
    containerId = 4
      ## Container ID type


  LibusbError* {.pure, size: sizeof(cint).} = enum
    ## Enumerates error codes.
    other = -99,
      ## Other error
    notSupported = -12,
      ## Operation not supported or unimplemented on this platform
    noMemory = -11,
      ## Insufficient memory.
    interrupted = -10,
      ## System call interrupted (perhaps due to signal)
    pipe = -9,
      ## Pipe error
    overflow = -8,
      ## Overflow.
    timeout = -7,
      ## Operation timed out
    busy = -6,
      ## Resource busy
    notFound = -5,
      ## Entity not found
    noDevice = -4,
      ## No such device (it may have been disconnected)
    access = -3,
      ## Access denied (insufficient permissions)
    invalidParam = -2,
      ## Invalid parameter
    io = -1,
      ## Input/output error
    success = 0
      ## Success (no error)

const
  libusbErrorCount* = 14
    ## Total number of error codes in `libusbError <#LibusbError>`_.


type
  LibusbTransferStatus* {.pure.} = enum
    ## Enumerats transfer status codes.
    completed,
      ## Transfer completed without error. Note that this does not indicate that
      ## the entire amount of requested data was transferred.
    error,
      ## Transfer failed
    timedOut,
      ## Transfer timed out
    cancelled,
      ## Transfer was cancelled
    stall,
      ## For bulk/interrupt endpoints: halt condition detected (endpoint
      ## stalled). For control endpoints: control request not supported.
    noDevice,
      ## Device was disconnected
    overflow
      ## Device sent more data than requested


  LibusbTransferFlags* {.pure.} = enum
    ## Enumerates `LibusbTransfer.flags <#LibusbTransfer.flags>`_ values.
    shortNotOk = 1 shl 0,
      ## Report short frames as errors
    freeBuffer = 1 shl 1,
      ## Automatically `free()` transfer buffer during
      ## `libusbFreeTransfer <#libusbFreeTransfer>`_
    freeTransfer = 1 shl 2,
      ## Automatically call `libusbFreeTransfer <#libusbFreeTransfer>`_ after
      ## callback returns. If this flag is set, it is illegal to call
      ## `libusbFreeTransfer <#libusbFreeTransfer>`_ from your transfer
      ## callback, as this will result in a double-free when this flag is acted
      ## upon.
    addZeroPacket = 1 shl 3
      ## Terminate transfers that are a multiple of the endpoint's
      ## `maxPacketSize <#LibusbEndpointDescriptor>`_ with an extra zero length
      ## packet. This is useful when a device protocol mandates that each
      ## logical request is terminated by an incomplete packet (i.e. the logical
      ## requests are not separated by other means).
      ##
      ## This flag only affects host-to-device transfers to bulk and interrupt
      ## endpoints. In other situations, it is ignored.
      ##
      ## This flag only affects transfers with a length that is a multiple of
      ## the endpoint's `maxPacketSize <#LibusbEndpointDescriptor>`_. On
      ## transfers of other lengths, this flag has no effect. Therefore, if you
      ## are working with a device that needs a ZLP whenever the end of the
      ## logical request falls on a packet boundary, then it is sensible to set
      ## this flag on every transfer (you do not have to worry about only
      ## setting it on transfers that end on the boundary).
      ##
      ## This flag is currently only supported on Linux. On other systems,
      ## `libusbSubmitTransfer <#libusbSubmitTransfer>`_ will return
      ## `LibusbError.notSupported <#LibusbError>`_ for every transfer where
      ## this flag is set.


type
  LibusbIsoPacketDescriptor* = object
    ## Isochronous packet descriptor.
    length*: cuint
      ## Length of data to request in this packet
    actualLength*: cuint
      ## Amount of data that was actually transferred
    status*: LibusbTransferStatus
      ## Status code for this packet


  LibusbIsoPacketDescriptorArray = UncheckedArray[LibusbIsoPacketDescriptor]
    ## Unchecked array of packet descriptors that will translate to C arrays of
    ## undetermined size as required in the ``iso_packet_desc`` field of the
    ## `LibusbTransfer <#LibusbTransfer>`_ object.


  LibusbTransferCbFn* = proc (transfer: ptr LibusbTransfer) {.fastcall.}
    ## Asynchronous transfer callback function type. When submitting
    ## asynchronous transfers, you pass a pointer to a callback function
    ## of this type via the ``callback`` member of the
    ## `LibusbTransfer <#LibusbTransfer>`_ object. libusb will call this
    ## function later, when the transfer has completed or failed.
    ##
    ## transfer
    ##   The `LibusbTransfer <#LibusbTransfer>`_ object that the callback
    ##   function is being notified about


  LibusbTransfer* = object
    ## Generic USB transfer structure. The user populates this structure and
    ## then submits it in order to request a transfer. After the transfer has
    ## completed, the library populates the transfer with the results and passes
    ## it back to the user.
    devHandle*: ptr LibusbDeviceHandle
      ## Handle of the device that this transfer will be submitted to
    flags*: uint8
      ## A bitwise OR combination of
      ## `LibusbTransferFlags <#LibusbTransferFlags>`_
    endpoint*: cuchar
      ## Address of the endpoint where this transfer will be sent
    transferType*: LibusbTransferType
      ## Type of the endpoint from `LibusbTransferType <#LibusbTransferType>`_.
    timeout*: cuint
      ## Timeout for this transfer in millseconds. A value of `0` indicates no
      ## timeout.
    status*: LibusbTransferStatus
      ## The status of the transfer. Read-only, and only for use within transfer
      ## callback function.
      ##
      ## If this is an isochronous transfer, this field may read COMPLETED even
      ## if there were errors in the frames. Use the
      ## `LibusbIsoPacketDescriptor.status` field in each packet to determine
      ## if errors occurred.
    length*: cint
      ## Length of the data buffer
    actualLength*: cint
      ## Actual length of data that was transferred. Read-only, and only for use
      ## within transfer callback function. Not valid for isochronous endpoint
      ## transfers.
    callback*: LibusbTransferCbFn
      ## Callback function. This will be invoked when the transfer completes,
      ## fails, or is cancelled.
    userData*: pointer
      ## User context data to pass to the callback function
    buffer*: cstring
      ## Data buffer
    numIsoPackets*: cint
      ## Number of isochronous packets. Only used for I/O with isochronous
      ## endpoints
    isoPacketDesc*: LibusbIsoPacketDescriptorArray
      ## Isochronous packet descriptors, for isochronous transfers only


type
  LibusbCapability* {.pure, size: sizeof(uint32).} = enum
    ## Enumerates capabilities supported by an instance of libusb on the current
    ## running platform. Test if the loaded library supports a given capability
    ## by calling `libusbHasCapability()`.
    hasCapability = 0x00000000,
      ## The `libusbHasCapability <#libusbHasCapability>`_ API is available
    hasHotplug = 0x00000001,
      ## Hotplug support is available on this platform
    hasHidAccess = 0x00000100,
      ## The library can access HID devices without requiring user intervention.
      ## Note that before being able to actually access an HID device, you may
      ## still have to call additional libusb functions such as
      ## `libusbDetachKernelDriver <#libusbDetachKernelDriver>`_.
    supportsDetachKernelDriver = 0x00000101
      ## The library supports detaching of the default USB driver, using
      ## `libusbDetachKernelDriver <#libusbDetachKernelDriver>`_, if one is set
      ## by the OS kernel.


  LibusbLogLevel* {.pure.} = enum
    ## Enumerates log message levels.
    none = 0,
      ## No messages ever printed by the library (default)
    error,
      ## Error messages are printed to stderr
    warning,
      ## Warning and error messages are printed to stderr
    info,
      ## Informational messages are printed to stdout, warning and error
      ## messages are printed to stderr
    debug
      ## Debug and informational messages are printed to stdout, warnings and
      ## errors to stderr


proc libusbInit*(ctx: ptr ptr LibusbContext): cint
  {.cdecl, dynlib: dllname, importc: "libusb_init".}
  ## Initializes libusb.
  ##
  ## context
  ##   Optional output location for context pointer. Only valid on return code
  ##   `LibusbError.success <#LibusbError>`_
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError <#LibusbError>`_ code on failure
  ##
  ## This function must be called before calling any other libusb function.
  ## If you do not provide an output location for a context pointer, a default
  ## context will be created. If there was already a default context, it will be
  ## reused (and nothing will be initialized/reinitialized).


proc libusbExit*(ctx: ptr LibusbContext)
  {.cdecl, dynlib: dllname, importc: "libusb_exit".}
  ## Shuts down libusb.
  ##
  ## ctx
  ##   The context to deinitialize, or ``nil`` for the default context.
  ##
  ## Should be called after closing all open devices and before your application
  ## terminates.


proc libusbSetDebug*(ctx: ptr LibusbContext; level: cint)
  {.cdecl, dynlib: dllname, importc: "libusb_set_debug".}
  ## Sets the log message verbosity.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## level
  ##   The debug level to set
  ##
  ## The default level is `LibusbLogLevel.none <#LibusbLogLevel>`_, which means
  ## no messages are ever printed. If you choose to increase the message
  ## verbosity level, ensure that your application does not close the stdout /
  ## stderr file descriptors.
  ##
  ## You are advised to use level `LibusbLogLevel.warning <#LibusbLogLevel>`_.
  ## libusb is conservative with its message logging and most of the time, will
  ## only log messages that explain error conditions and other oddities. This
  ## will help you debug your software.
  ##
  ## If the ``LIBUSB_DEBUG`` environment variable was set when libusb was
  ## initialized, this function does nothing: the message verbosity is fixed to
  ## the value in the environment variable.
  ##
  ## If libusb was compiled without any message logging, this function does
  ## nothing: you'll never get any messages. If libusb was compiled with verbose
  ## debug message logging, this function does nothing: you'll always get
  ## messages from all levels.


proc libusbGetVersion*(): ptr LibusbVersion
  {.cdecl, dynlib: dllname, importc: "libusb_get_version".}
  ## Gets the version (major, minor, micro, nano and rc) of the running library.
  ##
  ## result
  ##   An object containing the version number


proc libusbHasCapability*(capability: LibusbCapability): cint
  {.cdecl, dynlib: dllname, importc: "libusb_has_capability".}
  ## Checks at runtime if the loaded library has a given capability.
  ##
  ## capability
  ##   The `LibusbCapability <#LibusbCapability>`_ to check for
  ## result
  ##   - nonzero if the running library has the capability
  ##   - ``0`` otherwise.
  ##
  ## This call should be performed after `libusbInit <#libusbInit>`_, to ensure
  ## that the backend has updated its capability set.


proc libusbErrorName*(errcode: cint): cstring
  {.cdecl, dynlib: dllname, importc: "libusb_error_name".}
  ## Gets a constant nil-terminated string with the ASCII name of a libusb
  ## error or transfer status code.
  ##
  ## error_code
  ##   The `LibusbError <#LibusbError>`_ or
  ##   `LibusbTransferStatus <#LibusbTransferStatus>`_ code
  ## result
  ##   - The error name if `errcode` is known
  ##   - `"UNKNOWN"` if the value of `errcode` is not a known code
  ##
  ## The caller must not free the returned string.


proc libusbSetLocale*(locale: cstring): cint
  {.cdecl, dynlib: dllname, importc: "libusb_setlocale".}
  ## Set the language, and only the language, not the encoding! used for
  ## translatable libusb messages.
  ##
  ## locale
  ##   The locale-string in the form of ``lang[_country_region][.codeset]``
  ##   or ``lang[-region]``, where lang is a 2 letter ISO 639-1 code.
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.invalidParam <#LibusbError>`_ if the locale doesn't meet
  ##     the requirements
  ##   - `LibusbError.notFound <#LibusbError>`_ if the requested language is not
  ##     supported
  ##   - `LibusbError <#LibusbError>`_ code on other errors.
  ##
  ## This takes a locale string in the default setlocale format:
  ## - ``lang[-region]``, or
  ## - ``lang[_country_region][.codeset]``.
  ##
  ## Only the `lang` part of the string is used, and only 2 letter ISO 639-1
  ## codes are accepted for it, such as "de". The optional region,
  ## `country_region` or `codeset` parts are ignored. This means that functions
  ## which return translatable strings will NOT honor the specified encoding.
  ##
  ## All strings returned are encoded as UTF-8 strings. If
  ## `libusbSetLocale <#libusbSetLocale>`_ is not called, all messages will
  ## be in English. Note that the libusb log messages controlled through
  ## `libusbSetDebug <#libusbSetDebug>`_ are not translated, they are always in
  ## English.
  ##
  ## The following functions return translatable strings:
  ## - `libusbStrError <#libusbStrError>`_
  ##
  ## For POSIX UTF-8 environments if you want libusb to follow the standard
  ## locale settings, call `libusbSetLocale(setlocale(LC_MESSAGES, nil))`,
  ## after your app has done its locale setup.


proc libusbStrError*(errcode: cint): cstring
  {.cdecl, dynlib: dllname, importc: "libusb_strerror".}
  ## Get a constant string with a short description of the given error code.
  ##
  ## errcode
  ##   The error code whose description is desired
  ## result
  ##   - A short description of the error code in UTF-8 encoding.
  ##
  ## This description is intended for displaying to the end user and will be in
  ## the language set by `libusbSetLocale <#libusbSetLocale>`_. The returned
  ## string is encoded in UTF-8. The messages always start with a capital letter
  ## and end without any dot. The caller must not free the returned string.


proc libusbGetDeviceList*(ctx: ptr LibusbContext;
  list: ptr ptr LibusbDeviceArray): csize
  {.cdecl, dynlib: dllname, importc: "libusb_get_device_list".}
  ## Get a list of USB devices currently attached to the system.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## list
  ##   The output location for a list of devices. Must be later freed with
  ##   `libusbFreeDeviceList <#libusbFreeDeviceList>`_
  ## result
  ##   - the number of devices in the outputted list
  ##   - any `LibusbError <#LibusbError>`_ according to errors encountered by
  ##     the backend
  ##
  ## This is your entry point into finding a USB device to operate. You are
  ## expected to unreference all the devices when you are done with them, and
  ## then free the list with `libusbFreeDeviceList <#libusbFreeDeviceList>`_.
  ##
  ## Note that `libusbFreeDeviceList <#libusbFreeDeviceList>`_ can unref all the
  ## devices for you. Be careful not to unreference a device you are about to
  ## open until after you have opened it.
  ##
  ## The return value of this function indicates the number of devices in the
  ## resultant list. The list is actually one element larger, as it is
  ## NULL-terminated.


proc libusbFreeDeviceList*(list: ptr LibusbDeviceArray; unrefDevices: cint)
  {.cdecl, dynlib: dllname, importc: "libusb_free_device_list".}
  ## Free a list of devices previously discovered using
  ## `libusbGetDeviceList <#libusbGetDeviceList>`_.
  ##
  ## list
  ##   The list to free
  ## unrefDevices
  ##   Whether to unref the devices in the list
  ##
  ## If the `unrefDevices` parameter is set, the reference count of each
  ## device in the list is decremented by ``1``.


proc libusbRefDevice*(dev: ptr LibusbDevice): ptr LibusbDevice
  {.cdecl, dynlib: dllname, importc: "libusb_ref_device".}
  ## Increment the reference count of a device.
  ##
  ## dev
  ##   The device to reference
  ## result
  ##   The same device


proc libusbUnrefDevice*(dev: ptr LibusbDevice)
  {.cdecl, dynlib: dllname, importc: "libusb_unref_device".}
  ## Decrement the reference count of a device.
  ##
  ## dev
  ##   The device to unreference
  ##
  ## If the decrement operation causes the reference count to reach zero, the
  ## device shall be destroyed.


proc libusbGetConfiguration*(dev: ptr LibusbDeviceHandle; config: ptr cint):
  cint {.cdecl, dynlib: dllname, importc: "libusb_get_configuration".}
  ## Determine the configuration value of the currently active configuration.
  ##
  ## dev
  ##   A device handle
  ## config
  ##   Output location for the
  ##   `configurationValue <#LibusbConfigDescriptor>`_ of the active
  ##   configuration (only valid if `LibusbError.success <#LibusbError>`_ was
  ##   returned)
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError <#LibusbError>`_ codes for other failures
  ##
  ## You could formulate your own control request to obtain this information,
  ## but this function has the advantage that it may be able to retrieve the
  ## information from operating system caches (no I/O involved).
  ##
  ## If the OS does not cache this information, then this function will block
  ## while a control transfer is submitted to retrieve the information. This
  ## function will return a value of 0 in the config output parameter if the
  ## device is in unconfigured state.


proc libusbGetDeviceDescriptor*(dev: ptr LibusbDevice;
  desc: ptr LibusbDeviceDescriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_device_descriptor".}
  ## Get the USB device descriptor for a given device.
  ##
  ## dev
  ##   The device
  ## desc
  ##   Output location for the descriptor data
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError <#LibusbError>`_ code on failure
  ##
  ## This is a non-blocking function; the device descriptor is cached in memory.
  ## Note since libusb-1.0.16, `libusbApiVersion <#libusbApiVersion>`_ >=
  ## 0x01000102, this function always succeeds.


proc libusbGetActiveConfigDescriptor*(dev: ptr LibusbDevice;
  config: ptr ptr LibusbConfigDescriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_active_config_descriptor".}
  ## Get the USB configuration descriptor for the currently active
  ## configuration.
  ##
  ## dev
  ##   A device
  ## config
  ##   Output location for the USB configuration descriptor. Only valid if
  ##   `LibusbError.success <#LibusbError>`_ was returned. Must be freed with
  ##   `libusbFreeConfigDescriptor <#libusbFreeConfigDescriptor>`_ after use.
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if the device is in unconfigured
  ##     state
  ##   - `LibusbError <#LibusbError>`_ codes for other errors
  ##
  ## This is a non-blocking function which does not involve any requests being
  ## sent to the device.


proc libusbGetConfigDescriptor*(dev: ptr LibusbDevice;
  config_index: uint8; config: ptr ptr LibusbConfigDescriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_config_descriptor".}
  ## Get a USB configuration descriptor based on its index.
  ##
  ## dev
  ##   A device
  ## config_index
  ##   The index of the configuration you wish to retrieve
  ## config
  ##   Output location for the USB configuration descriptor. Only valid if
  ##   `LibusbError.success <#LibusbError>`_ was returned. Must be freed with
  ##   `libusbFreeConfigDescriptor <#libusbFreeConfigDescriptor>`_ after use.
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if the configuration does not
  ##     exist
  ##   - `LibusbError <#LibusbError>`_ codes for other errors
  ##
  ## This is a non-blocking function which does not involve any requests being
  ## sent to the device.


proc libusbGetConfigDescriptorByValue*(dev: ptr LibusbDevice;
  configurationValue: uint8; config: ptr ptr LibusbConfigDescriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_config_descriptor_by_value".}
  ## Gets a USB configuration descriptor with a specific configuration value.
  ##
  ## dev
  ##   A device
  ## configurationValue
  ##   The `configurationValue <#LibusbConfigDescriptor>`_ of the configuration
  ##   you wish to retrieve
  ## config
  ##   Output location for the USB configuration descriptor. Only valid if
  ##   `LibusbError.success <#LibusbError>`_ was returned. Must be freed with
  ##   `libusbFreeConfigDescriptor <#libusbFreeConfigDescriptor>`_ after use
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if the configuration does not
  ##     exist
  ##   - `LibusbError <#LibusbError>`_ codes for other errors
  ##
  ## This is a non-blocking function which does not involve any requests being
  ## sent to the device.


proc libusbFreeConfigDescriptor*(config: ptr LibusbConfigDescriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_config_descriptor".}
  ## Frees a configuration descriptor obtained from
  ## `libusbGetActiveConfigDescriptor <#libusbGetActiveConfigDescriptor>`_ or
  ## `libusbGetConfigDescriptor <#libusbGetConfigDescriptor>`_.
  ##
  ## config
  ##   The configuration descriptor to free
  ##
  ## It is safe to call this function with a ``nil`` config parameter, in which
  ## case the function simply returns.


proc libusbGetSsEndpointCompanionDescriptor*(ctx: ptr LibusbContext;
  endpoint: ptr LibusbEndpointDescriptor;
  epComp: ptr ptr LibusbSsEndpointCompanionDescriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_ss_endpoint_companion_descriptor".}
  ## Gets an endpoints superspeed endpoint companion descriptor (if any).
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context.
  ## endpoint
  ##   Endpoint descriptor from which to get the superspeed endpoint companion
  ##   descriptor
  ## epComp
  ##   Output location for the superspeed endpoint companion descriptor. Only
  ##   valid if `LibusbError.success <#LibusbError>`_ was returned. Must be
  ##   freed with after use with
  ##   `libusbFreeSsEndpointCompanionDescriptor <#libusbFreeSsEndpointCompanionDescriptor>`_.
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if the configuration does not exist
  ##   - `LibusbError <#LibusbError>`_ codes for other errors


proc libusbFreeSsEndpointCompanionDescriptor*(
  epComp: ptr LibusbSsEndpointCompanionDescriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_ss_endpoint_companion_descriptor".}
  ## Free a superspeed endpoint companion descriptor obtained from
  ## `libusbGetSsEndpointCompanionDescriptor <#libusbGetSsEndpointCompanionDescriptor>`_.
  ##
  ## epComp
  ##   The superspeed endpoint companion descriptor to free
  ##
  ## It is safe to call this function with a ``nil`` `epComp` parameter, in
  ## which case the function simply returns.


proc libusbGetBosDescriptor*(handle: ptr LibusbDeviceHandle;
  bos: ptr ptr LibusbBosDescriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_bos_descriptor".}
  ## Gets a Binary Object Store (BOS) descriptor.
  ##
  ## handle
  ##   The handle of an open libusb device
  ## bos
  ##   Output location for the BOS descriptor. Only valid if
  ##   `LibusbError.success <#LibusbError>`_ was returned.
  ##   Must be freed with `libusbFreeBosDescriptor <#libusbFreeBosDescriptor>`_
  ##   after use.
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if the device doesn't have a BOS
  ##     descriptor
  ##   - `LibusbError <#LibusbError>`_ codes for other errors
  ##
  ## This is a blocking function, which will send requests to the device.


proc libusbFreeBosDescriptor*(bos: ptr LibusbBosDescriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_bos_descriptor".}
  ## Frees a BOS descriptor obtained from `libusbGetBosDescriptor()`.
  ##
  ## bos
  ##   The BOS descriptor to free
  ##
  ## It is safe to call this function with a ``nil`` `bos` parameter, in which
  ## case the function simply returns.


proc libusbGetUsb20ExtensionDescriptor*(ctx: ptr LibusbContext;
  devCap: ptr LibusbBosDevCapabilityDescriptor;
  usb20Extension: ptr ptr LibusbUsb20ExtensionDescriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_usb_2_0_extension_descriptor".}
  ## Gets an USB 2.0 Extension descriptor.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## devCap
  ##   Device Capability descriptor with a `devCapabilityType` of
  ##   ``libusb_capability_type.extension``
  ## usb20Extension
  ##   Output location for the USB 2.0 Extension descriptor. Only valid if
  ##   `LibusbError.success <#LibusbError>`_ was returned. Must be freed with
  ##   `libusbFreeUsb20ExtensionDescriptor <#libusbFreeUsb20ExtensionDescriptor>`_
  ##   after use.
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError <#LibusbError>`_ code on error


proc libusbFreeUsb20ExtensionDescriptor*(
  usb20Extension: ptr LibusbUsb20ExtensionDescriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_usb_2_0_extension_descriptor".}
  ## Frees a USB 2.0 Extension descriptor obtained from
  ## `libusbGetUsb20ExtensionDescriptor <#libusbGetUsb20ExtensionDescriptor>`_.
  ##
  ## usb20Extension
  ##   The USB 2.0 Extension descriptor to free
  ##
  ## It is safe to call this function with a ``nil`` `usb20Extension`
  ## parameter, in which case the function simply returns.


proc libusbGetSsUsbDeviceCapabilityDescriptor*(ctx: ptr LibusbContext;
  devCap: ptr LibusbBosDevCapabilityDescriptor;
  ssUsbDeviceCap: ptr ptr LibusbSsUsbDeviceCapabilityDescriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_ss_usb_device_capability_descriptor".}
  ## Gets a SuperSpeed USB Device Capability descriptor.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## devCap
  ##   Device Capability descriptor with a `devCapabilityType` of
  ##   `LibusbBosType.ssUsbDeviceCapability <#LibusbBosType>`_
  ## ssUsbDeviceCap
  ##   Output location for the SuperSpeed USB Device Capability descriptor.
  ##   Only valid if `LibusbError.success <#LibusbError>`_ was returned. Must be
  ##   freed with
  ##   `libusbFreeSsUsbDeviceCapabilityDescriptor <#libusbFreeSsUsbDeviceCapabilityDescriptor>`_
  ##   after use.
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError <#LibusbError>`_ code on error


proc libusbFreeSsUsbDeviceCapabilityDescriptor*(
  ssUsbDeviceCap: ptr LibusbSsUsbDeviceCapabilityDescriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_ss_usb_device_capability_descriptor".}
  ## Frees a SuperSpeed USB Device Capability descriptor obtained from
  ## `libusbGetSsUsbDeviceCapabilityDescriptor()`.
  ##
  ## ssUsbDeviceCap
  ##   The USB 2.0 Extension descriptor to free
  ##
  ## It is safe to call this function with a ``nil`` `ssUsbDeviceCap parameter`,
  ## in which case the function simply returns.


proc libusbGetContainerIdDescriptor*(ctx: ptr LibusbContext;
  devCap: ptr LibusbBosDevCapabilityDescriptor;
  container_id: ptr ptr LibusbContainerIdDescriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_container_id_descriptor".}
  ## Gets a Container ID descriptor.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## devCap
  ##   Device Capability descriptor with a `devCapabilityType` of
  ##   `LibusbBosType.containerId <#LibusbBosType>`_
  ## container_id
  ##   Output location for the Container ID descriptor. Only valid if 0 was
  ##   returned. Must be freed with
  ##   `libusbFreeContainerIdDescriptor <#libusbFreeContainerIdDescriptor>`_
  ##   after use
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError <#LibusbError>`_ code on error


proc libusbFreeContainerIdDescriptor*(
  container_id: ptr LibusbContainerIdDescriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_container_id_descriptor".}
  ## Frees a Container ID descriptor obtained from
  ## `libusbGetContainerIdDescriptor <#libusbGetContainerIdDescriptor>`_.
  ##
  ## container_id
  ##   The USB 2.0 Extension descriptor to free
  ##
  ## It is safe to call this function with a ``nil`` `container_id` parameter,
  ## in which case the function simply returns.


proc libusbGetBusNumber*(dev: ptr LibusbDevice): uint8
  {.cdecl, dynlib: dllname, importc: "libusb_get_bus_number".}
  ## Gets the number of the bus that a device is connected to.
  ##
  ## dev
  ##   A device
  ## result
  ##   The bus number


proc libusbGetPortNumber*(dev: ptr LibusbDevice): uint8
  {.cdecl, dynlib: dllname, importc: "libusb_get_port_number".}
  ## Get the number of the port that a device is connected to.
  ##
  ## dev
  ##   A device
  ## result
  ##   The port number (0 if not available)
  ##
  ## Unless the OS does something funky, or you are hot-plugging USB extension
  ## cards, the port number returned by this call is usually guaranteed to be
  ## uniquely tied to a physical port, meaning that different devices plugged on
  ## the same physical port should return the same port number.
  ##
  ## But outside of this, there is no guarantee that the port number returned by
  ## this call will remain the same, or even match the order in which ports have
  ## been numbered by the HUB/HCD manufacturer.


proc libusbGetPortNumbers*(dev: ptr LibusbDevice;
  portNumbers: ptr uint8; portNumbersLen: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_port_numbers".}
  ## Get the list of all port numbers from root for the specified device.
  ##
  ## dev
  ##   A device
  ## portNumbers
  ##   The array that should contain the port numbers
  ## portNumbersLen
  ##   The maximum length of the array. As per the USB 3.0 specs, the current
  ##   maximum limit for the depth is 7
  ## result
  ##   - The number of elements filled
  ##   - `LibusbError.overflow <#LibusbError>`_ if the array is too small.


proc libusbGetParent*(dev: ptr LibusbDevice): ptr LibusbDevice
  {.cdecl, dynlib: dllname, importc: "libusb_get_parent".}
  ## Get the the parent from the specified device.
  ##
  ## dev
  ##   A device
  ## reuslt
  ##   - The device parent
  ##   - ``nil`` if not available
  ##
  ## You should issue a `libusbGetDeviceList <#libusbGetDeviceList>`_ before
  ## calling this function and make sure that you only access the parent before
  ## issuing `libusbFreeDeviceList <#libusbFreeDeviceList>`_. The reason is that
  ## libusb currently does not maintain a permanent list of device instances,
  ## and therefore can only guarantee that parents are fully instantiated within
  ## a `libusbGetDeviceList <#libusbGetDeviceList>`_ -
  ## `libusbFreeDeviceList <#libusbFreeDeviceList>`_ block.


proc libusbGetDeviceAddress*(dev: ptr LibusbDevice): uint8
  {.cdecl, dynlib: dllname, importc: "libusb_get_device_address".}
  ## Get the address of the device on the bus it is connected to.
  ##
  ## dev
  ##   A device
  ## result
  ##   The device address


proc libusbGetDeviceSpeed*(dev: ptr LibusbDevice): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_device_speed".}
  ## Get the negotiated connection speed for a device.
  ##
  ## dev
  ##   A device
  ## result
  ##   - `LibusbSpeed <#LibusbSpeed>`_, where
  ##     `LibusbSpeed.unknown <#LibusbSpeed>`_ means that the OS doesn't know or
  ##     doesn't support returning the negotiated speed.


proc libusbGetMaxPacketSize*(dev: ptr LibusbDevice; endpoint: cuchar): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_max_packet_size".}
  ## Convenience function to retrieve the
  ## `maxPacketSize <#LibusbEndpointDescriptor>`_ value for a particular
  ## endpoint in the active device configuration.
  ##
  ## dev
  ##   A device
  ## endpoint
  ##   Address of the endpoint in question
  ## result
  ##   - The `maxPacketSize <#LibusbEndpointDescriptor>`_ value
  ##   - `LibusbError.notFound <#LibusbError>`_ if the endpoint does not exist
  ##   - `LibusbError.other <#LibusbError>`_ on other failure
  ##
  ## This function was originally intended to be of assistance when setting up
  ## isochronous transfers, but a design mistake resulted in this function
  ## instead. It simply returns the `maxPacketSize <#LibusbEndpointDescriptor>`_
  ## value without considering its contents. If you're dealing with isochronous
  ## transfers, you probably want
  ## `libusbGetMaxIsoPacketSize <#libusbGetMaxIsoPacketSize>`_ instead.


proc libusbGetMaxIsoPacketSize*(dev: ptr LibusbDevice; endpoint: cuchar): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_max_iso_packet_size".}
  ## Calculate the maximum packet size which a specific endpoint is capable is
  ## sending or receiving in the duration of 1 microframe.
  ##
  ## dev
  ##   A device
  ## endpoint
  ##   Address of the endpoint in question
  ## result
  ##   - The maximum packet size which can be sent/received on this endpoint
  ##   - `LibusbError.notFound <#LibusbError>`_ if the endpoint does not exist
  ##   - `LibusbError.other <#LibusbError>`_ on other failure
  ##
  ## Only the active configuration is examined. The calculation is based on the
  ## `maxPacketSize <#LibusbEndpointDescriptor>`_ field in the endpoint
  ## descriptor as described in section 9.6.6 in the USB 2.0 specifications.
  ##
  ## If acting on an isochronous or interrupt endpoint, this function will
  ## multiply the value found in bits 0:10 by the number of transactions per
  ## microframe (determined by bits 11:12). Otherwise, this function just
  ## returns the numeric value found in bits 0:10.
  ##
  ## This function is useful for setting up isochronous transfers, for example
  ## you might pass the return value from this function to
  ## `libusbSetIsoPacketLengths <#libusbSetIsoPacketLengths>`_ in order to set
  ## the length field of every isochronous packet in a transfer.


proc libusbOpen*(dev: ptr LibusbDevice; handle: ptr ptr LibusbDeviceHandle):
  cint {.cdecl, dynlib: dllname, importc: "libusb_open".}
  ## Open a device and obtain a device handle.
  ##
  ## dev
  ##   The device to open
  ## handle
  ##   Output location for the returned device handle pointer. Only populated
  ##   when the return code is `LibusbError.success <#LibusbError>`_
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.noMemory <#LibusbError>`_ on memory allocation failure
  ##   - `LibusbError.access <#LibusbError>`_ if the user has insufficient
  ##     permissions
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError <#LibusbError>`_ codes on other failures
  ##
  ## A handle allows you to perform I/O on the device in question. Internally,
  ## this function adds a reference to the device and makes it available to you
  ## through `libusbGetDevice <#libusbGetDevice>`_. This reference is removed
  ## during `libusbClose <#libusbClose>`_.
  ##
  ## This is a non-blocking function; no requests are sent over the bus.


proc libusbClose*(devHandle: ptr LibusbDeviceHandle)
  {.cdecl, dynlib: dllname, importc: "libusb_close".}
  ## Close a device handle.
  ##
  ## devHandle
  ##   The handle to close
  ##
  ## Should be called on all open handles before your application exits.
  ## Internally, this function destroys the reference that was added by
  ## `libusbOpen <#libusbOpen>`_ on the given device.
  ##
  ## This is a non-blocking function; no requests are sent over the bus.


proc libusbGetDevice*(devHandle: ptr LibusbDeviceHandle): ptr LibusbDevice
  {.cdecl, dynlib: dllname, importc: "libusb_get_device".}
  ## Get the underlying device for a handle.
  ##
  ## devHandle
  ##   A device handle
  ## result
  ##   The underlying device
  ##
  ## This function does not modify the reference count of the returned device,
  ## so do not feel compelled to unreference it when you are done.


proc libusbSetConfiguration*(dev: ptr LibusbDeviceHandle;
  configuration: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_set_configuration".}
  ## Determine the ``configurationValue`` of the currently active configuration.
  ##
  ## dev
  ##   A device handle
  ## config
  ##   Output location for the
  ##   `configurationValue <#LibusbConfigDescriptor>`_ of the active
  ##   configuration (only valid if `LibusbError.success <#LibusbError>`_ is
  ##   returned).
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError <#LibusbError>`_ codes on other failures
  ##
  ## You could formulate your own control request to obtain this information,
  ## but this function has the advantage that it may be able to retrieve the
  ## information from operating system caches (no I/O involved).
  ##
  ## If the OS does not cache this information, then this function will block
  ## while a control transfer is submitted to retrieve the information. This
  ## function will return a value of 0 in the config output parameter if the
  ## device is in unconfigured state.


proc libusbClaimInterface*(dev: ptr LibusbDeviceHandle;
  interfaceNumber: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_claim_interface".}
  ## Claim an interface on a given device handle.
  ##
  ## dev
  ##   A device handle
  ## interfaceNumber
  ##   The interface number of the interface you wish to claim
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if the requested interface does
  ##     not exist
  ##   - `LibusbError.busy <#LibusbError>`_ if another program or driver has
  ##     claimed the interface
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError <#LibusbError>`_ codeS on other failures
  ##
  ## You must claim the interface you wish to use before you can perform I/O on
  ## any of its endpoints. It is legal to attempt to claim an already-claimed
  ## interface, in which case libusb just returns 0 without doing anything.
  ##
  ## If `auto_detach_kernel_driver` is set to 1 for dev, the kernel driver
  ## will be detached if necessary, on failure the detach error is returned.
  ## Claiming of interfaces is a purely logical operation; it does not cause any
  ## requests to be sent over the bus. Interface claiming is used to instruct
  ## the underlying operating system that your application wishes to take
  ## ownership of the interface.
  ##
  ## This is a non-blocking function.
  ##
  ## See also `libusbAttachIKernelDriver <#libusbAttachIKernelDriver>`_,
  ## `libusbDetachKernelDriver <#libusbDetachKernelDriver>`_,
  ## `libusbSetAutoDetachKernelDriver <#libusbSetAutoDetachKernelDriver>`_


proc libusbReleaseInterface*(dev: ptr LibusbDeviceHandle;
  interfaceNumber: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_release_interface".}
  ## Release an interface previously claimed with
  ## `libusbClaimInterface <#libusbClaimInterface>`_.
  ##
  ## dev
  ##   A device handle
  ## interfaceNumber
  ##   The interface number of the previously-claimed interface
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if the interface was not
  ##     claimed
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError <#LibusbError>`_ codes on other failures
  ##
  ## You should release all claimed interfaces before closing a device handle.
  ## A `setInterface <#LibusbStandardRequest>`_ control request will be sent to
  ## the device, resetting interface state to the first alternate setting.
  ##
  ## If `auto_detach_kernel_driver` is set to 1 for dev, the kernel driver will
  ## be re-attached after releasing the interface.
  ##
  ## This is a blocking function.


proc libusbOpenDeviceWithVidPid*(ctx: ptr LibusbContext;
  vendorId: cshort; productId: cshort): ptr LibusbDeviceHandle
  {.cdecl, dynlib: dllname, importc: "libusb_open_device_with_vid_pid".}
  ## Convenience function for finding a device with a particular idVendor /
  ## idProduct combination.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## vendorId
  ##   The idVendor value to search for
  ## productId
  ##   The idProduct value to search for
  ## result
  ##   - a handle for the first found device
  ##   - ``nil`` on error or if the device could not be found.
  ##
  ## This function is intended for those scenarios where you are using libusb to
  ## knock up a quick test application - it allows you to avoid calling
  ## `libusbGetDeviceList <#libusbGetDeviceList>`_ and worrying about traversing
  ## or freeing the list. This function has limitations and is hence not
  ## intended for use in real applications: if multiple devices have the same
  ## IDs it will only give you the first one, etc.



proc libusbSetInterfaceAltSetting*(dev: ptr LibusbDeviceHandle;
  interfaceNumber: cint; alternateSetting: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_set_interface_alt_setting".}
  ## Activate an alternate setting for an interface.
  ##
  ## dev
  ##   A device handle
  ## interfaceNumber
  ##   The ``interfaceNumber`` of the previously-claimed interface
  ## alternateSetting
  ##   The ``alternateSetting`` of the alternate setting to activate
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if the interface was not
  ##     claimed, or the requested alternate setting does not exist
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError <#LibusbError>`_ codes on other failures
  ##
  ## The interface must have been previously claimed with
  ## `libusbClaimInterface <#libusbClaimInterface>`. You should always use this
  ## function rather than formulating your own
  ## `setInterface <#LibusbStandardRequest>`_ control request. This is because
  ## the underlying operating system needs to know when such changes happen.
  ##
  ## This is a blocking function.


proc libusbClearHalt*(dev: ptr LibusbDeviceHandle; endpoint: cuchar): cint
  {.cdecl, dynlib: dllname, importc: "libusb_clear_halt".}
  ## Clear the halt/stall condition for an endpoint.
  ##
  ## dev
  ##   A device handle
  ## endpoint
  ##   The endpoint to clear halt status
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if the endpoint does not exist
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError <#LibusbError>`_ code on other failure
  ##
  ## Endpoints with halt status are unable to receive or transmit data until the
  ## halt condition is stalled. You should cancel all pending transfers before
  ## attempting to clear the halt condition.
  ##
  ## This is a blocking function.


proc libusbResetDevice*(dev: ptr LibusbDeviceHandle): cint
  {.cdecl, dynlib: dllname, importc: "libusb_reset_device".}
  ## Perform a USB port reset to reinitialize a device.
  ##
  ## dev
  ##   A handle of the device to reset
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if re-enumeration is required,
  ##     or if the device has been disconnected
  ##   - `LibusbError <#LibusbError>`_ codes on other failures
  ##
  ## The system will attempt to restore the previous configuration and alternate
  ## settings after the reset has completed. If the reset fails, the descriptors
  ## change, or the previous state cannot be restored, the device will appear to
  ## be disconnected and reconnected. This means that the device handle is no
  ## longer valid (you should close it) and rediscover the device. A return code
  ## of `LibusbError.notFound <#LibusbError>`_ indicates when this is the case.
  ##
  ## This is a blocking function which usually incurs a noticeable delay.


proc libusbAllocStreams*(dev: ptr LibusbDeviceHandle;
  numStreams: uint32; endpoints: ptr cuchar; numEndpoints: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_alloc_streams".}
  ## Allocate up to ``numStreams`` usb bulk streams on the specified endpoints.
  ##
  ## dev
  ##   A device handle
  ## numStreams
  ##   Number of streams to try to allocate
  ## endpoints
  ##   Array of endpoints to allocate streams on
  ## numEndpoints
  ##   Length of the endpoints array
  ## result
  ##   - number of streams allocated
  ##   - `LibusbError <#LibusbError>`_ codes on failure
  ##
  ## This function takes an array of endpoints rather then a single endpoint
  ## because some protocols require that endpoints are setup with similar stream
  ## ids. All endpoints passed in must belong to the same interface.
  ##
  ## Note this function may return less streams then requested. Also note that
  ## the same number of streams are allocated for each endpoint in the endpoint
  ## array. Stream id ``0`` is reserved, and should not be used to communicate
  ## with devices. If `libusbAllocStreams <#libusbAllocStreams>`_ returns with a
  ## value of ``N``, you may use stream ids ``1`` to ``N``.


proc libusbFreeStreams*(dev: ptr LibusbDeviceHandle;
  endpoints: ptr cuchar; numEndpoints: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_free_streams".}
  ## Free usb bulk streams allocated with
  ## `libusbAllocStreams <#libusbAllocStreams>`_.
  ##
  ## dev
  ##   A device handle
  ## endpoints
  ##   Array of endpoints to free streams on
  ## numEndpoints
  ##   Length of the endpoints array
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError <#LibusbError>`_ codes on failure
  ##
  ## Note streams are automatically free-ed when releasing an interface.


proc libusbKernelDriverActive*(dev: ptr LibusbDeviceHandle;
  interfaceNumber: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_kernel_driver_active".}
  ## Determine if a kernel driver is active on an interface.
  ##
  ## dev
  ##   A device handle
  ## interfaceNumber
  ##   The interface to check
  ## result
  ##   - ``0`` if no kernel driver is active
  ##   - ``1`` if a kernel driver is active
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError.notSupported <#LibusbError>`_ on platforms where the
  ##     functionality is not available
  ##   - `LibusbError <#LibusbError>`_ codes on other failures
  ##
  ## If a kernel driver is active, you cannot claim the interface, and libusb
  ## will be unable to perform I/O. This functionality is not available on
  ## Windows.


proc libusbDetachKernelDriver*(dev: ptr LibusbDeviceHandle;
  interfaceNumber: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_detach_kernel_driver".}
  ## Detach a kernel driver from an interface.
  ##
  ## dev
  ##   A device handle
  ## interfaceNumber
  ##   The interface to detach the driver from
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if no kernel driver was active
  ##   - `LibusbError.invalidParam <#LibusbError>`_ if the interface does not
  ##     exist
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError.notSupported <#LibusbError>`_ on platforms where the
  ##     functionality is not available,
  ##   - `LibusbError <#LibusbError>`_ codes on other failures
  ##
  ## If successful, you will then be able to claim the interface and perform
  ## I/O. This functionality is not available on Darwin or Windows. Note that
  ## libusb itself also talks to the device through a special kernel driver, if
  ## this driver is already attached to the device, this call will not detach it
  ## and return `LibusbError.notFound <#LibusbError>`_.


proc libusbAttachIKernelDriver*(dev: ptr LibusbDeviceHandle;
  interfaceNumber: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_attach_kernel_driver".}
  ## Re-attach an interface's kernel driver, which was previously detached using
  ## `libusbDetachKernelDriver <#libusbDetachKernelDriver>`_.
  ##
  ## dev
  ##   A device handle
  ## interfaceNumber
  ##   The interface to attach the driver from
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if no kernel driver was active
  ##   - `LibusbError.invalidParam <#LibusbError>`_ if the interface does not
  ##     exist
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError.notSupported <#LibusbError>`_ on platforms where the
  ##     functionality is not available
  ##   - `LibusbError.busy <#LibusbError>`_ if the driver cannot be attached
  ##     because the
  ##     interface is claimed by a program or driver
  ##   - `LibusbError <#LibusbError>`_ codes on other failures
  ##
  ## This call is only effective on Linux and returns
  ## `LibusbError.notSupported <#LibusbError>`_ on all other platforms. This
  ## functionality is not available on Darwin or Windows.


proc libusbSetAutoDetachKernelDriver*(dev: ptr LibusbDeviceHandle;
  enable: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_set_auto_detach_kernel_driver".}
  ## Enable/disable libusb's automatic kernel driver detachment.
  ##
  ## When this is enabled libusb will automatically detach the kernel driver on
  ## an interface when claiming the interface, and attach it when releasing the
  ## interface. Automatic kernel driver detachment is disabled on newly opened
  ## device handles by default.
  ##
  ## On platforms which do not have
  ## `LibusbCapability.supportsDetachKernelDriver <#LibusbCapability>`_ this
  ## function will return `LibusbError.notSupported <#LibusbError>`_, and libusb
  ## will continue as if this function was never called.
  ##
  ## dev
  ##   A device handle
  ## enable
  ##   Whether to enable or disable auto kernel driver detachment
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError.notSupported <#LibusbError>`_ on platforms where the
  ##     functionality is not available.


# Async I/O ####################################################################

proc libusbControlTransferGetData*(transfer: ptr LibusbTransfer):
  ptr cuchar {.inline.} =
  ## Get the data section of a control transfer.
  ##
  ## transfer
  ##   A transfer
  ## result
  ##   A pointer to the first byte of the data section
  ##
  ## This convenience function is here to remind you that the data does not
  ## start until 8 bytes into the actual buffer, as the setup packet comes
  ## first. Calling this function only makes sense from a transfer callback
  ## function, or situations where you have already allocated a suitably sized
  ## buffer at `transfer.buffer <#LibusbTransfer>`_.
  return cast[ptr cuchar](cast[int](transfer.buffer) + sizeof(LibusbControlSetup))


proc libusbControlTransferGetSetup*(transfer: ptr LibusbTransfer):
  ptr LibusbControlSetup {.inline.} =
  ## Get the control setup packet of a control transfer.
  ##
  ## transfer
  ##   A transfer
  ## result
  ##   A casted pointer to the start of the transfer data buffer
  ##
  ## This convenience function is here to remind you that the control setup
  ## occupies the first 8 bytes of the transfer data buffer. Calling this
  ## function only makes sense from a transfer callback function, or situations
  ## where you have already allocated a suitably sized buffer at
  ## `transfer.buffer <#LibusbTransfer>`_.
  return cast[ptr LibusbControlSetup](transfer.buffer)


proc libusbFillControlSetup*(buffer: ptr cuchar; bmRequestType: uint8;
  request: uint8; value: uint16; index: uint16; length: uint16) {.inline.} =
  ## Helper function to populate the setup packet (first 8 bytes of the data
  ## buffer) for a control transfer.
  ##
  ## buffer
  ##   Buffer to output the setup packet into. This pointer must be aligned to
  ##   at least 2 bytes boundary
  ## bmRequestType
  ##   See the `bmRequestType` field of
  ##   `LibusbControlSetup <#LibusbControlSetup>`_
  ## request
  ##   See the `request` field of `LibusbControlSetup <#LibusbControlSetup>`_
  ## value
  ##   See the `value` field of `LibusbControlSetup <#LibusbControlSetup>`_
  ## index
  ##   See the `index` field of `LibusbControlSetup <#LibusbControlSetup>`_
  ## length
  ##   See the `length` field of `LibusbControlSetup <#LibusbControlSetup>`_
  ##
  ## The `index`, `value` and `length` values should be given in host-endian
  ## byte order.
  var setup: ptr LibusbControlSetup =
    cast[ptr LibusbControlSetup](cast[pointer](buffer))
  setup.bmRequestType = bmRequestType
  setup.request = request
  setup.value = libusbCpuToLe16(value)
  setup.index = libusbCpuToLe16(index)
  setup.length = libusbCpuToLe16(length)


proc libusbAllocTransfer*(isoPackets: cint): ptr LibusbTransfer
  {.cdecl, dynlib: dllname, importc: "libusb_alloc_transfer".}
  ## Allocate a libusb transfer with a specified number of isochronous packet
  ## descriptors.
  ##
  ## isoPackets
  ##   Number of isochronous packet descriptors to allocate
  ## result
  ##   A newly allocated transfer, or ``nil`` on error
  ##
  ## The returned transfer is pre-initialized for you. When the new transfer is
  ## no longer needed, it should be freed with
  ## `libusbFreeTransfer <#libusbFreeTransfer>`_. Transfers intended for
  ## non-isochronous endpoints (e.g. control, bulk, interrupt) should specify an
  ## ``isoPackets`` count of zero.
  ##
  ## For transfers intended for isochronous endpoints, specify an appropriate
  ## number of packet descriptors to be allocated as part of the transfer. The
  ## returned transfer is not specially initialized for isochronous I/O; you are
  ## still required to set the `numIsoPackets <#LibusbTransfer.numIsoPackets>`_
  ## and type fields accordingly.
  ##
  ## It is safe to allocate a transfer with some isochronous packets and then
  ## use it on a non-isochronous endpoint. If you do this, ensure that at time
  ## of submission, `numIsoPackets <#LibusbTransfer.numIsoPackets>`_ is ``0``
  ## and that type is set appropriately.


proc libusbSubmitTransfer*(transfer: ptr LibusbTransfer): cint
  {.cdecl, dynlib: dllname, importc: "libusb_submit_transfer".}
  ## Submit a transfer.
  ##
  ## transfer
  ##   The transfer to submit
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success,
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError.busy <#LibusbError>`_ if the transfer has already been
  ##     submitted
  ##   - `LibusbError.notSupported <#LibusbError>`_ if the transfer flags are
  ##     not supported
  ##     by the operating system
  ##   - `LibusbError <#LibusbError>`_ codes for other failures
  ##
  ## This function will fire off the USB transfer and then return immediately.


proc libusbCancelTransfer*(transfer: ptr LibusbTransfer): cint
  {.cdecl, dynlib: dllname, importc: "libusb_cancel_transfer".}
  ## Asynchronously cancel a previously submitted transfer.
  ##
  ## transfer
  ##    The transfer to cancel
  ## result
  ##   - 0 on success
  ##   - `LibusbError.notFound <#LibusbError>`_ if the transfer is already
  ##     complete or cancelled
  ##   - `LibusbError <#LibusbError>`_ codes for other failures
  ##
  ## This function returns immediately, but this does not indicate that
  ## cancellation is complete. Your callback function will be invoked at some
  ## later time with a transfer status of
  ## `LibusbTransferStatus.cancelled <#LibusbTransferStatus>`_.


proc libusbFreeTransfer*(transfer: ptr LibusbTransfer)
  {.cdecl, dynlib: dllname, importc: "libusb_free_transfer".}
  ## Free a transfer structure.
  ##
  ## transfer
  ##   The transfer to free
  ##
  ## This should be called for all transfers allocated with
  ## `libusbAllocTransfer <#libusbAllocTransfer>`_. If the
  ## `LibusbTransferFlags.freeBuffer <#LibusbTransferFlags>`_ flag is set and
  ## the transfer buffer is not ``nil``, this function will also free the
  ## transfer buffer using the standard system memory allocator.
  ##
  ## It is legal to call this function with a ``nil`` transfer. In this case,
  ## the function will simply return safely. It is not legal to free an active
  ## transfer (one which has been submitted and has not yet completed).


proc libusbTransferSetStreamId*(transfer: ptr LibusbTransfer;
  streamId: uint32)
  {.cdecl, dynlib: dllname, importc: "libusb_transfer_set_stream_id".}
  ## Set a transfers bulk stream id.
  ##
  ## transfer
  ##   The transfer to set the stream id for
  ## streamId
  ##   The stream id to set
  ##
  ## Note users are advised to use
  ## `libusbFillBulkStreamTransfer <#libusbFillBulkStreamTransfer>`_ instead of
  ## calling this function directly.


proc libusbTransferGetStreamId*(transfer: ptr LibusbTransfer): uint32
  {.cdecl, dynlib: dllname, importc: "libusb_transfer_get_stream_id".}
  ## Get a transfers bulk stream identifier.
  ##
  ## transfer
  ##   The transfer to get the stream identifier for
  ## result
  ##   - the stream identifier for the transfer


proc libusbFillControlTransfer*(transfer: ptr LibusbTransfer;
  devHandle: ptr LibusbDeviceHandle; buffer: ptr cuchar;
  callback: LibusbTransferCbFn; userData: pointer; timeout: cuint)
  {.inline.} =
  ## Helper function to populate the `LibusbTransfer <#LibusbTransfer>`_ fields
  ## for a control transfer.
  ##
  ## transfer
  ##   The transfer to populate
  ## devHandle
  ##   Handle of the device that will handle the transfer
  ## buffer
  ##   Data buffer. If provided, this function will interpret the first 8 bytes
  ##   as a setup packet and infer the transfer length from that. This pointer
  ##   must be aligned to at least 2 bytes boundary.
  ## callback
  ##   Callback function to be invoked on transfer completion
  ## userData
  ##   User data to pass to callback function
  ## timeout
  ##   Timeout for the transfer in milliseconds
  ##
  ## If you pass a transfer buffer to this function, the first 8 bytes will be
  ## interpreted as a control setup packet, and the ``length`` field will be
  ## used to automatically populate the ``length`` field of the transfer.
  ## Therefore the recommended approach is:
  ## - Allocate a suitably sized data buffer (including space for control setup)
  ## - Call `libusbFillControlSetup <#libusbFillControlSetup>`_
  ## - If this is a host-to-device transfer with a data stage, put the data
  ##   in place after the setup packet
  ## - Call this function
  ## - Call `libusbSubmitTransfer <#libusbSubmitTransfer>`_
  ##
  ## It is also legal to pass a ``nil`` buffer to this function, in which case
  ## this function will not attempt to populate the length field. Remember that
  ## you must then populate the buffer and length fields later.
  var setup: ptr LibusbControlSetup = cast[ptr LibusbControlSetup](buffer)
  transfer.devHandle = devHandle
  transfer.endpoint = '\0'
  transfer.transferType = LibusbTransferType.control
  transfer.timeout = timeout
  transfer.buffer = buffer
  if setup != nil:
    transfer.length = (cint)sizeof(LibusbControlSetup) + (cint)libusbLe16ToCpu(setup.length)
  transfer.userData = userData
  transfer.callback = callback


proc libusbFillBulkTransfer*(transfer: ptr LibusbTransfer;
  devHandle: ptr LibusbDeviceHandle; endpoint: cuchar; buffer: ptr cuchar;
  length: cint; callback: LibusbTransferCbFn; userData: pointer;
  timeout: cuint) {.inline.} =
  ## Helper function to populate the `LibusbTransfer <#LibusbTransfer>`_ fields
  ## for a bulk transfer.
  ##
  ## transfer
  ##   The transfer to populate
  ## devHandle
  ##   Handle of the device that will handle the transfer
  ## endpoint
  ##   Address of the endpoint where this transfer will be sent
  ## buffer
  ##   Data buffer
  ## length
  ##   Length of data buffer
  ## callback
  ##   Callback function to be invoked on transfer completion
  ## userData
  ##   User data to pass to callback function
  ## timeout
  ##   Timeout for the transfer in milliseconds
  transfer.endpoint = endpoint
  transfer.transferType = LibusbTransferType.bulk
  transfer.timeout = timeout
  transfer.buffer = buffer
  transfer.length = length
  transfer.userData = userData
  transfer.callback = callback


proc libusbFillBulkStreamTransfer*(transfer: ptr LibusbTransfer;
  devHandle: ptr LibusbDeviceHandle; endpoint: cuchar; streamId: uint32;
  buffer: ptr cuchar; length: cint; callback: LibusbTransferCbFn;
  userData: pointer; timeout: cuint) {.inline.} =
  ## Helper function to populate the `LibusbTransfer <#LibusbTransfer>`_ fields
  ## for a bulk transfer using bulk streams.
  ##
  ## transfer
  ##   The transfer to populate
  ## devHandle
  ##   Handle of the device that will handle the transfer
  ## endpoint
  ##   Address of the endpoint where this transfer will be sent
  ## streamId
  ##   Bulk stream id for this transfer
  ## buffer
  ##   Data buffer
  ## length
  ##   Length of data buffer
  ## callback
  ##   Callback function to be invoked on transfer completion
  ## userData
  ##   User data to pass to callback function
  ## timeout
  ##   Timeout for the transfer in milliseconds
  libusbFillBulkTransfer(transfer, devHandle, endpoint, buffer, length,
    callback, userData, timeout)
  transfer.transferType = LibusbTransferType.bulkStream
  libusbTransferSetStreamId(transfer, streamId)


proc libusbFillInterruptTransfer*(transfer: ptr LibusbTransfer;
  devHandle: ptr LibusbDeviceHandle; endpoint: cuchar; buffer: ptr cuchar;
  length: cint; callback: LibusbTransferCbFn; userData: pointer;
  timeout: cuint) {.inline.} =
  ## Helper function to populate the `LibusbTransfer <#LibusbTransfer>`_ fields
  ## for an interrupt transfer.
  ##
  ## transfer
  ##   The transfer to populate
  ## devHandle
  ##   Handle of the device that will handle the transfer
  ## endpoint
  ##   Address of the endpoint where this transfer will be sent
  ## buffer
  ##   Data buffer
  ## length
  ##   Length of data buffer
  ## callback
  ##   Callback function to be invoked on transfer completion
  ## userData
  ##   User data to pass to callback function
  ## timeout
  ##   Timeout for the transfer in milliseconds
  transfer.devHandle = devHandle
  transfer.endpoint = endpoint
  transfer.transferType = LibusbTransferType.interrupt
  transfer.timeout = timeout
  transfer.buffer = buffer
  transfer.length = length
  transfer.userData = userData
  transfer.callback = callback


proc libusbFillIsoTransfer*(transfer: ptr LibusbTransfer;
  devHandle: ptr LibusbDeviceHandle; endpoint: cuchar; buffer: ptr cuchar;
  length: cint; numIsoPackets: cint; callback: LibusbTransferCbFn;
  userData: pointer; timeout: cuint) {.inline.} =
  ## Helper function to populate the `LibusbTransfer <#LibusbTransfer>`_ fields
  ## for an isochronous transfer.
  ##
  ## transfer
  ##   The transfer to populate
  ## devHandle
  ##   Handle of the device that will handle the transfer
  ## endpoint
  ##   Address of the endpoint where this transfer will be sent
  ## buffer
  ##   Data buffer
  ## length
  ##   Length of data buffer
  ## numIsoPackets
  ##   The number of isochronous packets
  ## callback
  ##   Callback function to be invoked on transfer completion
  ## userData
  ##   User data to pass to callback function
  ## timeout
  ##   Timeout for the transfer in milliseconds
  transfer.devHandle = devHandle
  transfer.endpoint = endpoint
  transfer.transferType = LibusbTransferType.isochronous
  transfer.timeout = timeout
  transfer.buffer = buffer
  transfer.length = length
  transfer.numIsoPackets = numIsoPackets
  transfer.userData = userData
  transfer.callback = callback


proc libusbSetIsoPacketLengths*(transfer: ptr LibusbTransfer;
  length: cuint) {.inline.} =
  ## Convenience function to set the length of all packets in an isochronous
  ## transfer, based on the numIsoPackets field in the transfer structure.
  ##
  ## transfer
  ##   A transfer
  ## length
  ##   The length to set in each isochronous packet descriptor
  ##   (see `libusbGetMaxPacketSize <#libusbGetMaxPacketSize>`_
  var i: cint
  i = 0
  while i < transfer.numIsoPackets:
    transfer.isoPacketDesc[i].length = length
    inc(i)


proc libusbGetIsoPacketBuffer*(transfer: ptr LibusbTransfer; packet: cuint):
  ptr cuchar {.inline.} =
  ## Convenience function to locate the position of an isochronous packet within
  ## the buffer of an isochronous transfer.
  ##
  ## transfer
  ##   A transfer
  ## packet
  ##   The packet to return the address of
  ## result
  ##   - The base address of the packet buffer inside the transfer buffer
  ##   - ``nil`` if the packet does not exist
  ##
  ## This is a thorough function which loops through all preceding packets,
  ## accumulating their lengths to find the position of the specified packet.
  ## Typically you will assign equal lengths to each packet in the transfer,
  ## and hence the above method is sub-optimal. Consider using
  ## `libusbGetIsoPacketBufferSimple <#libusbGetIsoPacketBufferSimple>`_
  ## instead.
  var i: cint
  var offset: cuint = 0
  var p: cint
  # oops..slight bug in the API. packet is an unsigned int, but we use
  #   signed integers almost everywhere else. range-check and convert to
  #   signed to avoid compiler warnings. FIXME for libusb-2.
  if packet > (cuint)int32.high: return nil
  p = cast[cint](packet)
  if p >= transfer.numIsoPackets: return nil
  i = 0
  while i < p:
    offset += transfer.iso_packet_desc[i].length
    inc(i)
  return cast[ptr cuchar](cast[cuint](transfer.buffer) + offset)


proc libusbGetIsoPacketBufferSimple*(transfer: ptr LibusbTransfer;
  packet: cuint): ptr cuchar {.inline.} =
  ## Convenience function to locate the position of an isochronous packet
  ## within the buffer of an isochronous transfer, for transfers where each
  ## packet is of identical size.
  ##
  ## transfer
  ##   A transfer
  ## packet
  ##   The packet to return the address of
  ## result
  ##   - The base address of the packet buffer inside the transfer buffer
  ##   - ``nil`` if the packet does not exist (see
  ##     `libusbGetIsoPacketBuffer <#libusbGetIsoPacketBuffer>`_).
  ##
  ## This function relies on the assumption that every packet within the
  ## transfer is of identical size to the first packet. Calculating the location
  ## of the packet buffer is then just a simple calculation:
  ##
  ##    <tt>buffer + (packet_size * packet)</tt>
  ##
  ## Do not use this function on transfers other than those that have identical
  ## packet lengths for each packet.
  var p: cint
  # oops..slight bug in the API. packet is an unsigned int, but we use
  #   signed integers almost everywhere else. range-check and convert to
  #   signed to avoid compiler warnings. FIXME for libusb-2.
  if packet > (cuint)int32.high:
    return nil
  p = cast[cint](packet)
  if p >= transfer.numIsoPackets:
    return nil
  return cast[ptr cuchar](cast[cuint](transfer.buffer) +
    (transfer.iso_packet_desc[0].length * packet))


# Sync I/O #####################################################################

proc libusbControlTransfer*(devHandle: ptr LibusbDeviceHandle;
  bmRequestType: uint8; request: LibusbStandardRequest;
  value: uint16; index: uint16; data: ptr cuchar; length: uint16;
  timeout: cuint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_control_transfer".}
  ## Perform a USB control transfer.
  ##
  ## devHandle
  ##   A handle for the device to communicate with
  ## bmRequestType
  ##   The request type field for the setup packet
  ## request
  ##   The request field for the setup packet
  ## value
  ##   The value field for the setup packet
  ## index
  ##   The index field for the setup packet
  ## data
  ##   A suitably-sized data buffer for either input or output (depending on
  ##   direction bits within bmRequestType)
  ## length
  ##   The length field for the setup packet. The data buffer should be at least
  ##   this size
  ## timeout
  ##   Timeout (in millseconds) that this function should wait before giving up
  ##   due to no response being received. For an unlimited timeout, use ``0``
  ## result
  ##   - on success, the number of bytes actually transferred
  ##   - `LibusbError.timeout <#LibusbError>`_ if the transfer timed out
  ##   - `LibusbError.pipe <#LibusbError>`_ if the control request was not
  ##     supported by the device
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError <#LibusbError>`_ codes on other failures
  ##
  ## The direction of the transfer is inferred from the bmRequestType field of
  ## the setup packet. The `value`, `index` and `length` fields values should
  ## be given in host-endian byte order.


proc libusbBulkTransfer*(devHandle: ptr LibusbDeviceHandle;
  endpoint: cuchar; data: ptr cuchar; length: cint; actualLength: ptr cint;
  timeout: cuint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_bulk_transfer".}
  ## Perform a USB bulk transfer.
  ##
  ## devHandle
  ##   A handle for the device to communicate with
  ## endpoint
  ##   The address of a valid endpoint to communicate with
  ## data
  ##   A suitably-sized data buffer for either input or output(depending on
  ##   endpoint)
  ## length
  ##   For bulk writes, the number of bytes from data to be sent. For bulk
  ##   reads, the maximum number of bytes to receive into the data buffer
  ## transferred
  ##   Output location for the number of bytes actually transferred
  ## timeout
  ##   Timeout (in millseconds) that this function should wait before giving up
  ##   due to no response being received. For an unlimited timeout, use ``0``
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success (and populates
  ##     transferred data)
  ##   - `LibusbError.timeout <#LibusbError>`_ if the transfer timed out (and
  ##     populates transferred)
  ##   - `LibusbError.pipe <#LibusbError>`_ if the endpoint halted
  ##   - `LibusbError.overflow <#LibusbError>`_ if the device offered more data,
  ##     see Packets and overflows
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError <#LibusbError>`_ codes on other failures
  ##
  ## The direction of the transfer is inferred from the direction bits of the
  ## endpoint address. For bulk reads, the length field indicates the maximum
  ## length of data you are expecting to receive. If less data arrives than
  ## expected, this function will return that data, so be sure to check the
  ## transferred output parameter.
  ##
  ## You should also check the transferred parameter for bulk writes. Not all of
  ## the data may have been written. Also check transferred when dealing with a
  ## timeout error code. libusb may have to split your transfer into a number of
  ## chunks to satisfy underlying O/S requirements, meaning that the timeout may
  ## expire after the first few chunks have completed. libusb is careful not to
  ## lose any data that may have been transferred; do not assume that timeout
  ## conditions indicate a complete lack of I/O.


proc libusbInterruptTransfer*(devHandle: ptr LibusbDeviceHandle;
  endpoint: cuchar; data: ptr cuchar; length: cint; actualLength: ptr cint;
  timeout: cuint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_interrupt_transfer".}
  ## Perform a USB interrupt transfer.
  ##
  ## devHandle
  ##   A handle for the device to communicate with
  ## endpoint
  ##   The address of a valid endpoint to communicate with
  ## data
  ##   A suitably-sized data buffer for either input or output (depending on
  ##   endpoint)
  ## length
  ##   For bulk writes, the number of bytes from data to be sent. For bulk
  ##   reads, the maximum number of bytes to receive into the data buffer
  ## actualLength
  ##   Output location for the number of bytes actually transferred
  ## timeout
  ##   Timeout (in millseconds) that this function should wait before giving up
  ##   due to no response being received. For an unlimited timeout, use ``0``
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success (and populates
  ##     transferred data)
  ##   - `LibusbError.timeout <#LibusbError>`_ if the transfer timed out
  ##   - `LibusbError.pipe <#LibusbError>`_ if the endpoint halted
  ##   - `LibusbError.overflow <#LibusbError>`_ if the device offered more data,
  ##     see Packets and overflows
  ##   - `LibusbError.noDevice <#LibusbError>`_ if the device has been
  ##     disconnected
  ##   - `LibusbError <#LibusbError>`_ codes on other errors
  ##
  ## The direction of the transfer is inferred from the direction bits of the
  ## endpoint address. For interrupt reads, the length field indicates the
  ## maximum length of data you are expecting to receive. If less data arrives
  ## than expected, this function will return that data, so be sure to check the
  ## transferred output parameter.
  ##
  ## You should also check the transferred parameter for interrupt writes.
  ## Not all of the data may have been written. Also check transferred when
  ## dealing with a timeout error code. libusb may have to split your transfer
  ## into a number of chunks to satisfy underlying O/S requirements, meaning
  ## that the timeout may expire after the first few chunks have completed.
  ## libusb is careful not to lose any data that may have been transferred;
  ## do not assume that timeout conditions indicate a complete lack of I/O.
  ##
  ## The default endpoint interval value is used as the polling interval.


proc libusbGetDescriptor*(dev: ptr LibusbDeviceHandle; descType: uint8;
  descIndex: uint8; data: ptr cuchar; length: cint): cint {.inline.} =
  ## Retrieve a descriptor from the default control pipe.
  ##
  ## dev
  ##   A device handle
  ## descType
  ##   The descriptor type, see `LibusbDescriptorType <#LibusbDescriptorType>`_
  ## descIndex
  ##    The index of the descriptor to retrieve
  ## data
  ##   Output buffer for descriptor
  ## length
  ##   Size of data buffer
  ## result
  ##   - Number of bytes returned in data
  ##   - `LibusbError <#LibusbError>`_ code on failure
  ##
  ## This is a convenience function which formulates the appropriate control
  ## message to retrieve the descriptor.
  return libusbControlTransfer(
    dev,
    uint8(LibusbEndpointDirection.hostToDevice) or
      uint8(LibusbRequestType.class) or
      uint8(LibusbRequestRecipient.interf),
    LibusbStandardRequest.getDescriptor,
    (uint16)((desc_type shl 8) or desc_index),
    0,
    data,
    cast[uint16](length),
    1000)


proc libusbGetStringDescriptor*(dev: ptr LibusbDeviceHandle; descIndex: uint8;
  langid: uint16; data: ptr cuchar; length: cint): cint {.inline.} =
  ## Retrieve a descriptor from a device.
  ##
  ## dev
  ##   A device handle
  ## descIndex
  ##   The index of the descriptor to retrieve
  ## langid
  ##   The language ID for the string descriptor
  ## data
  ##   Output buffer for descriptor
  ## length
  ##   Size of data buffer
  ## result
  ##   - Number of bytes returned in data
  ##   - `LibusbError <#LibusbError>`_ codes on failure
  ##
  ## This is a convenience function which formulates the appropriate control
  ## message to retrieve the descriptor. The string returned is Unicode, as
  ## detailed in the USB specifications.
  return libusbControlTransfer(
    dev,
    uint8(LibusbEndpointDirection.hostToDevice) or
      uint8(LibusbRequestType.class) or
      uint8(LibusbRequestRecipient.interf),
    LibusbStandardRequest.getDescriptor,
    (uint16)((((int16)LibusbDescriptorType.str) shl 8) or (int16)desc_index),
    langid,
    data,
    cast[uint16](length), 1000)


proc libusbGetStringDescriptorAscii*(dev: ptr LibusbDeviceHandle;
  descIndex: uint8; data: ptr cuchar; length: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_string_descriptor_ascii".}
  ## Retrieve a string descriptor in C style ASCII.
  ##
  ## dev
  ##   A device handle
  ## descIndex
  ##   The index of the descriptor to retrieve
  ## data
  ##   Output buffer for ASCII string descriptor
  ## length
  ##   Size of data buffer
  ## result
  ##   - Number of bytes returned in data
  ##   - `LibusbError <#LibusbError>`_ codes on failure
  ##
  ## Uses the first language supported by the device.


# Polling and timeouts #########################################################

proc libusbTryLockEvents*(ctx: ptr LibusbContext): cint
  {.cdecl, dynlib: dllname, importc: "libusb_try_lock_events".}
  ## Attempt to acquire the event handling lock. This lock is used to ensure
  ## that only one thread is monitoring libusb event sources at any one time.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## result
  ##   - ``0`` if the lock was obtained successfully
  ##   - ``1`` if the lock was not obtained (i.e. another thread holds the lock)
  ##
  ## You only need to use this lock if you are developing an application which
  ## calls `poll()` or `select()` on libusb's file descriptors directly. If you
  ## stick to libusb's event handling loop functions, i.e.
  ## `libusbHandleEvents <#libusbHandleEvents>`_ then you do not need to be
  ## concerned with this locking.
  ##
  ## While holding this lock, you are trusted to actually be handling events.
  ## If you are no longer handling events, you must call
  ## `libusbUnlockEvents <#libusbUnlockEvents>`_ as soon as possible.


proc libusbLockEvents*(ctx: ptr LibusbContext)
  {.cdecl, dynlib: dllname, importc: "libusb_lock_events".}
  ## Acquire the event handling lock, blocking until successful acquisition if
  ## it is contended.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ##
  ## This lock is used to ensure that only one thread is monitoring libusb event
  ## sources at any one time. You only need to use this lock if you are
  ## developing an application which calls `poll()` or `select()` on libusb's
  ## file descriptors directly. If you stick to libusb's event handling loop
  ## functions (e.g. `libusbHandleEvents <#libusbHandleEvents>`_) then you
  ## do not need to be concerned with this locking.
  ##
  ## While holding this lock, you are trusted to actually be handling events.
  ## If you are no longer handling events, you must call
  ## `libusbUnlockEvents <#libusbUnlockEvents>`_ as soon as possible.


proc libusbUnlockEvents*(ctx: ptr LibusbContext)
  {.cdecl, dynlib: dllname, importc: "libusb_unlock_events".}
  ## Release the lock previously acquired with
  ## `libusbTryLockEvents <#libusbTryLockEvents>`_ or
  ## `libusbLockEvents <#libusbLockEvents>`_.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ##
  ## Releasing this lock will wake up any threads blocked on
  ## `libusbWaitForEvent <#libusbWaitForEvent>`_.


proc libusbEventHandlingOk*(ctx: ptr LibusbContext): cint
  {.cdecl, dynlib: dllname, importc: "libusb_event_handling_ok".}
  ## Determine if it is still OK for this thread to be doing event handling.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## result
  ##   - ``1`` if event handling can start or continue
  ##   - ``0`` if this thread must give up the events lock
  ##
  ## Sometimes, libusb needs to temporarily pause all event handlers, and this
  ## is the function you should use before polling file descriptors to see if
  ## this is the case. If this function instructs your thread to give up the
  ## events lock, you should just continue the usual logic that is documented in
  ## Multi-threaded applications and asynchronous I/O. On the next iteration,
  ## your thread will fail to obtain the events lock, and will hence become an
  ## event waiter.
  ##
  ## This function should be called while the events lock is held: you don't
  ## need to worry about the results of this function if your thread is not the
  ## current event handler.


proc libusbEventHandlerActive*(ctx: ptr LibusbContext): cint
  {.cdecl, dynlib: dllname, importc: "libusb_event_handler_active".}
  ## Determine if an active thread is handling events (i.e. if anyone is holding
  ## the event handling lock).
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## result
  ##   - ``1`` if a thread is handling events
  ##   - ``0`` if there are no threads currently handling events


proc libusbLockEventWaiters*(ctx: ptr LibusbContext)
  {.cdecl, dynlib: dllname, importc: "libusb_lock_event_waiters".}
  ## Acquire the event waiters lock.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ##
  ## This lock is designed to be obtained under the situation where you want to
  ## be aware when events are completed, but some other thread is event handling
  ## so calling libusbHandleEvents() is not allowed. You then obtain this
  ## lock, re-check that another thread is still handling events, then call
  ## `libusbWaitForEvent <#libusbWaitForEvent>`_.
  ##
  ## You only need to use this lock if you are developing an application which
  ## calls `poll()` or `select()` on libusb's file descriptors directly, and may
  ## potentially be handling events from 2 threads simultaenously. If you stick
  ## to libusb's event handling loop functions (e.g. `libusbHandleEvents()`)
  ## then you do not need to be concerned with this locking.


proc libusbUnlockEventWaiters*(ctx: ptr LibusbContext)
  {.cdecl, dynlib: dllname, importc: "libusb_unlock_event_waiters".}
  ## Release the event waiters lock.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context


proc libusbWaitForEvent*(ctx: ptr LibusbContext; tv: ptr LibusbTimeval): cint
  {.cdecl, dynlib: dllname, importc: "libusb_wait_for_event".}
  ## Wait for another thread to signal completion of an event.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## tv
  ##   Maximum timeout for this blocking function. A ``nil`` value indicates
  ##   unlimited timeout.
  ## result
  ##   - ``0`` after a transfer completes or another thread stops event handling
  ##   - ``1`` if the timeout expired
  ##
  ## Must be called with the event waiters lock held, see
  ## `libusbLockEventWaiters <#libusbLockEventWaiters>`_. This function
  ## will block until any of the following conditions are met:
  ##
  ##    1. The timeout expires
  ##    2. A transfer completes
  ##    3. thread releases the event handling lock through
  ##       `libusbUnlockEvents <#libusbUnlockEvents>`_
  ##
  ## Condition 1 is obvious. Condition 2 unblocks your thread after the callback
  ## for the transfer has completed. Condition 3 is important because it means
  ## that the thread that was previously handling events is no longer doing so,
  ## so if any events are to complete, another thread needs to step up and start
  ## event handling.
  ##
  ## This function releases the event waiters lock before putting your thread to
  ## sleep, and reacquires the lock as it is being woken up.


proc libusbHandleEvents*(ctx: ptr LibusbContext): cint
  {.cdecl, dynlib: dllname, importc: "libusb_handle_events".}
  ## Handle any pending events in blocking mode.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError <#LibusbError>`_ codes on failure
  ##
  ## There is currently a timeout hardcoded at 60 seconds but we plan to make it
  ## unlimited in future. For finer control over whether this function is
  ## blocking or non-blocking, or for control over the timeout, use
  ## `libusbHandleEventsTimeoutCompleted <#libusbHandleEventsTimeoutCompleted>`_
  ## instead.
  ##
  ## This function is kept primarily for backwards compatibility. Use
  ## `libusbHandleEventsCompleted <#libusbHandleEventsCompleted>`_ or
  ## `libusbHandleEventsTimeoutCompleted <#libusbHandleEventsTimeoutCompleted>`_
  ## to avoid race conditions.


proc libusbHandleEventsTimeoutCompleted*(ctx: ptr LibusbContext;
  tv: ptr LibusbTimeval; completed: ptr cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_handle_events_timeout_completed".}
  ## Handle any pending events.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## tv
  ##   The maximum time to block waiting for events, or an all zero
  ##   `LibusbTimeval <#LibusbTimeval>`_ struct for non-blocking mode
  ## completed
  ##   Pointer to completion integer to check, or ``nil``
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError <#LibusbError>`_ codes on failure
  ##
  ## libusb determines "pending events" by checking if any timeouts have expired
  ## and by checking the set of file descriptors for activity.
  ##
  ## If a zero `tv` is passed, this function will handle any already-pending
  ## events and then immediately return in non-blocking style. If a non-zero
  ## `tv` is passed and no events are currently pending, this function will
  ## block waiting for events to handle up until the specified timeout.
  ##
  ## If an event arrives or a signal is raised, this function will return early.
  ## If the parameter completed is not ``nil`` then after obtaining the event
  ## handling lock this function will return immediately if the integer pointed
  ## to is not ``0``. This allows for race free waiting for the completion of a
  ## specific transfer.


proc libusbHandleEventsCompleted*(ctx: ptr LibusbContext; completed: ptr cint):
  cint {.cdecl, dynlib: dllname, importc: "libusb_handle_events_completed".}
  ## Handle any pending events in blocking mode.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## completed
  ##   Pointer to completion integer to check, or nil
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError <#LibusbError>`_ codec on failure
  ##
  ## Like `libusbHandleEvents <#libusbHandleEvents>`_, with the addition of
  ## a completed parameter to allow for race free waiting for the completion of
  ## a specific transfer. See
  ## `libusbHandleEventsTimeoutCompleted <#libusbHandleEventsTimeoutCompleted>`_
  ## for details on the completed parameter.


proc libusbHandleEventsLocked*(ctx: ptr LibusbContext; tv: ptr LibusbTimeval):
  cint {.cdecl, dynlib: dllname, importc: "libusb_handle_events_locked".}
  ## Handle any pending events by polling file descriptors, without checking if
  ## any other threads are already doing so.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## tv
  ##   The maximum time to block waiting for events, or zero for non-blocking
  ##   mode
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError <#LibusbError>`_ codes on failure
  ##
  ## Must be called with the event lock held, see
  ## `libusbLockEvents <#libusbLockEvents>`_. This function is designed to be
  ## called under the situation where you have taken the event lock and are
  ## calling `poll()/select()` directly on libusb's file descriptors (as opposed
  ## to using `libusbHandleEventsXXX` or similar). You detect events on libusb's
  ## descriptors, so you then call this function with a zero timeout value
  ## (while still holding the event lock).


proc libusbPollfdsHandleTimeouts*(ctx: ptr LibusbContext): cint
  {.cdecl, dynlib: dllname, importc: "libusb_pollfds_handle_timeouts".}
  ## Determines whether your application must apply special timing
  ## considerations when monitoring libusb's file descriptors.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## result
  ##   - ``0`` if you must call into libusb at times determined by
  ##     `libusbGetNextTimeout <#libusbGetNextTimeout>`_
  ##   - ``1`` if all timeout events are handled internally or through regular
  ##     activity on the file descriptors
  ##
  ## This function is only useful for applications which retrieve and poll
  ## libusb's file descriptors in their own main loop (The more advanced
  ## option). Ordinarily, libusb's event handler needs to be called into at
  ## specific moments in time (in addition to times when there is activity on
  ## the file descriptor set).
  ##
  ## The usual approach is to use `libusbGetNextTimeout <#libusbGetNextTimeout>`_
  ## to learn about when the next timeout occurs, and to adjust your
  ## `poll() / select()` timeout accordingly so that you can make a call into
  ## the library at that time.
  ##
  ## Some platforms supported by libusb do not come with this baggage - any
  ## events relevant to timing will be represented by activity on the file
  ## descriptor set, and `libusbGetNextTimeout <#libusbGetNextTimeout>`_ will
  ## always return ``0``. This function allows you to detect whether you are
  ## running on such a platform.


proc libusbGetNextTimeout*(ctx: ptr LibusbContext; tv: ptr LibusbTimeval): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_next_timeout".}
  ## Determine the next internal timeout that libusb needs to handle.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## tv
  ##   Output location for a relative time against the current clock in which
  ##   libusb must be called into in order to process timeout events
  ## result
  ##   - ``0`` if there are no pending timeouts
  ##   - ``1`` if a timeout was returned
  ##   - `LibusbError.other <#LibusbError>`_ on failure
  ##
  ## You only need to use this function if you are calling `poll()` or
  ## `select()` or similar on libusb's file descriptors yourself. You do not
  ## need to use it if you are calling
  ## `libusbHandleEvents <#libusbHandleEvents>`_ or a variant directly.
  ##
  ## You should call this function in your main loop in order to determine how
  ## long to wait for select() or poll() to return results. libusb needs to be
  ## called into at this timeout, so you should use it as an upper bound on your
  ## `select()` or `poll()` call.
  ##
  ## When the timeout has expired, call into `libusb_handle_events_timeout()`
  ## (perhaps in non-blocking mode) so that libusb can handle the timeout.
  ##
  ## This function may return ``1`` (success) and an all-zero `tv`. If this
  ## is the case, it indicates that libusb has a timeout that has already
  ## expired so you should call libusb_handle_events_timeout() or similar
  ## immediately. A return code of ``0`` indicates that there are no pending
  ## timeouts.
  ##
  ## On some platforms, this function will always returns ``0`` (no pending
  ## timeouts). See Notes on time-based events.


type
  LibusbPollfd* = object
    ## File descriptor for polling.
    fd*: cint ## Numeric file descriptor
    events*: cshort ## Event flags to poll for from <poll.h>. POLLIN indicates
      ## that you should monitor this file descriptor for becoming ready to read
      ## from, and POLLOUT indicates that you should monitor this file
      ## descriptor for nonblocking write readiness.


type
  LibusbPollfdAddedCb* = proc (fd: cint; events: cshort; userData: pointer)
    ## Callback function, invoked when a new file descriptor should be added to
    ## the set of file descriptors monitored for events.
    ##
    ## fd
    ##   The new file descriptor
    ## events
    ##   Events to monitor for (see `LibusbPollfd <#LibusbPollfd>`_ for details)
    ## userData
    ##   User data pointer specified in the
    ##   `libusbSetPollfdNotifiers <#libusbSetPollfdNotifiers>`_ call


type
  LibusbPollfdRemovedCb* = proc (fd: cint; userData: pointer)
    ## Callback function, invoked when a file descriptor should be removed from
    ## the set of file descriptors being monitored for events. After returning
    ## from this callback, do not use that file descriptor again.
    ##
    ## fd
    ##   The file descriptor to stop monitoring
    ## userData
    ##   User data pointer specified in their
    ##   `libusbSetPollfdNotifiers <#libusbSetPollfdNotifiers>`_ call


proc libusbGetPollfds*(ctx: ptr LibusbContext): ptr ptr LibusbPollfd
  {.cdecl, dynlib: dllname, importc: "libusb_get_pollfds".}
  ## Retrieve a list of file descriptors that should be polled by your main loop
  ## as libusb event sources.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## result
  ##   - NULL-terminated list of `LibusbPollfd <#LibusbPollfd>`_ structures
  ##   - ``nil`` on error
  ##   - ``nil`` on platforms where the functionality is not available
  ##
  ## The returned list is NULL-terminated and should be freed with `free()` when
  ## done. The actual list contents must not be touched. As file descriptors are
  ## a Unix-specific concept, this function is not available on Windows and will
  ## always return ``nil``.


proc libusbSetPollfdNotifiers*(ctx: ptr LibusbContext;
  addedCb: LibusbPollfdAddedCb; removedCb: LibusbPollfdRemovedCb;
  userData: pointer)
  {.cdecl, dynlib: dllname, importc: "libusb_set_pollfd_notifiers".}
  ## Register notification functions for file descriptor additions/removals.
  ##
  ## ctx
  ##   The context to operate on, or ``nil`` for the default context
  ## addedCb
  ##   Pointer to function for addition notifications
  ## removedCb
  ##    Pointer to function for removal notifications
  ## userData
  ##    User data to be passed back to callbacks (useful for passing context
  ##    information)
  ##
  ## These functions will be invoked for every new or removed file descriptor
  ## that libusb uses as an event source. To remove notifiers, pass ``nil``
  ## values for the function pointers.
  ##
  ## Note that file descriptors may have been added even before you register
  ## these notifiers (e.g. at `libusbInit <#libusbInit>`_ time). Additionally,
  ## note that the removal notifier may be called during
  ## `libusbExit <#libusbExit>`_ (e.g. when it is closing file descriptors that
  ## were opened and added to the poll set at `libusbInit <#libusbInit>`_ time).
  ## If you don't want this, remove the notifiers immediately before calling
  ## `libusbExit <#libusbExit>`_.


type
  LibusbHotplugCallbackHandle* = cint
    ## Callback handle.
    ##
    ## Callbacks handles are generated by
    ## `libusbHotplugRegisterCallback <#libusbHotplugRegisterCallback>`_ and
    ## can be used to deregister callbacks. Callback handles are unique per
    ## `LibusbContext <#LibusbContext>`_ and it is safe to call
    ## `libusbHotplugDeregisterCallback <#libusbHotplugDeregisterCallback>`_ on
    ## an already deregisted callback.


type
  LibusbHotplugFlag* {.pure, size: sizeof(cint).} = enum
    ## Enumerates flags for hotplug events.
    noFlags = 0, ## Default value when not using any flags.
    enumerate = 1 shl 0 ## Arm the callback and fire it for all
      ## matching currently attached devices.


const
  libusbHotplugDeviceArrived* = 0x00000001 ## A device has been plugged in and
    ## is ready to use.
  libusbHotplugDeviceLeft* = 0x00000002 ## A device has left and is no longer
    ## available. It is the user's responsibility to call
    ## `libusbClose <#libusbClose>`_ on any handle associated with a
    ## disconnected device. It is safe to call
    ## `libusbGetDeviceDescriptor <#libusbGetDeviceDescriptor>`_ on a device
    ## that has left.


const
  libusbHotplugMatchAny* = - 1 ## Wildcard matching for hotplug events.


type
  LibusbHotplugCallbackFn* = proc (ctx: ptr LibusbContext;
    device: ptr LibusbDevice; event: cint; userData: pointer): cint
    ## Hotplug callback function type. When requesting hotplug event
    ## notifications, you pass a pointer to a callback function of this type.
    ##
    ## ctx
    ##   Context of this notification
    ## device
    ##   The `LibusbDevice <#LibusbDevice>`_ this event occurred on
    ## event
    ##   Event that occurred
    ## userData
    ##   User data provided when this callback was registered
    ## result
    ##   - bool whether this callback is finished processing events;
    ##     returning 1 will cause this callback to be deregistered
    ##
    ## This callback may be called by an internal event thread and as such it is
    ## recommended the callback do minimal processing before returning. libusb
    ## will call this function later, when a matching event had happened on a
    ## matching device.
    ##
    ## It is safe to call either
    ## `libusbHotplugRegisterCallback <#libusbHotplugRegisterCallback>`_ or
    ## `libusbHotplugDeregisterCallback <#libusbHotplugDeregisterCallback>`_
    ## from within a callback function.


proc libusbHotplugRegisterCallback*(ctx: ptr LibusbContext; events: cint;
  flags: LibusbHotplugFlag; vendorId: cint; productId: cint; devClass: cint;
  cbFn: LibusbHotplugCallbackFn; userData: pointer;
  handle: ptr LibusbHotplugCallbackHandle): cint
  {.cdecl, dynlib: dllname, importc: "libusb_hotplug_register_callback".}
  ## Register a hotplug callback function.
  ##
  ## ctx
  ##   Context to register this callback with
  ## events
  ##   Bitwise or of events that will trigger this callback (see
  ##   `libusbHotplugDeviceXXX <#libusbHotplugDeviceArrived>`_ flags)
  ## flags
  ##   Hotplug callback flags (see `LibusbHotplugFlag`)
  ## vendorId
  ##   The vendor id to match, or
  ##   `libusbHotplugMatchAny <#libusbHotplugMatchAny>`_
  ## productId
  ##   The product id to match, or
  ##   `libusbHotplugMatchAny <#libusbHotplugMatchAny>`_
  ## devClass
  ##   The device class to match, or
  ##   `libusbHotplugMatchAny <#libusbHotplugMatchAny>`_
  ## cbFn
  ##   The function to be invoked on a matching event/device
  ## userData
  ##   User data to pass to the callback function
  ## handle
  ##   Pointer to store the handle of the allocated callback (can be ``nil``).
  ## result
  ##   - `LibusbError.success <#LibusbError>`_ on success
  ##   - `LibusbError <#LibusbError>`_ codes on failure
  ##
  ## The callback will fire when a matching event occurs on a matching device.
  ## It is active until either it is deregistered with
  ## `libusbHotplugDeregisterCallback <#libusbHotplugDeregisterCallback>`_ or
  ## the supplied callback returns ``1`` to indicate that it is finished
  ## processing events. If the `LibusbHotplugFlag.enumerate
  ## <#LibusbHotplugFlag>`_ flag is passed, the callback will be called with
  ## `libusbHotplugDeviceArrived <#libusbHotplugDeviceArrived>`_ for all devices
  ## already plugged into the machine.
  ##
  ## Note that libusb modifies its internal device list from a separate thread,
  ## while calling hotplug callbacks from
  ## `libusbHandleEvents <#libusbHandleEvents>`_, so it is possible for a device
  ## to already be present on, or removed from, its internal device list, while
  ## the hotplug callbacks still need to be dispatched. This means that, when
  ## using `LibusbHotplugFlag.enumerate <#LibusbHotplugFlag>`_, your callback
  ## may be called twice for the arrival of the same device, once from
  ## `libusbHotplugRegisterCallback <#libusbHotplugRegisterCallback>`_ and once
  ## from `libusbHandleEvents <#libusbHandleEvents>`_; and/or your callback
  ## may be called for the removal of a device for which an arrived call was
  ## never made.
  ##
  ## See also
  ## `libusbHotplugDeregisterCallback <#libusbHotplugDeregisterCallback>`_


proc libusbHotplugDeregisterCallback*(ctx: ptr LibusbContext;
  handle: LibusbHotplugCallbackHandle)
  {.cdecl, dynlib: dllname, importc: "libusb_hotplug_deregister_callback".}
  ## De-register a hotplug callback.
  ##
  ## ctx
  ##   The context that this callback is registered with
  ## handle
  ##   The handle of the callback to deregister
  ##
  ## Deregister a callback from a `LibusbContext <#LibusbContext>`_. This
  ## function is safe to call from within a hotplug callback.
  ##
  ## See also `libusbHotplugRegisterCallback <#libusbHotplugRegisterCallback>`_
