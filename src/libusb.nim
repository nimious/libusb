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

{.deadCodeElim: on.}


when defined(linux):
  const dllname = "libusb.so"
elif defined(macos):
  const dllname = "libusb.dylib"
elif defined(windows):
  const dllname = "libusb.dll"
else:
  {.error: "Platform does not support libspnav".}


const 
  LIBUSB_API_VERSION* = 0x01000103  # libusb API version


proc libusb_cpu_to_le16*(x: uint16): uint16 {.inline.} =
  ##  Converts a 16-bit value from host-endian to little-endian format.
  var tmp: uint16
  littleEndian16(addr tmp, addr x)
  return tmp


template libusb_le16_to_cpu*(x: uint16): uint16 {.inline.} =
  ## Converts a 16-bit value from little-endian to host-endian format.
  libusb_cpu_to_le16(x)


type 
  libusb_class_code* = enum ## \
    ## Enumerates USB device class codes.
    LIBUSB_CLASS_PER_INTERFACE = 0, ## each interface has its own class
    LIBUSB_CLASS_AUDIO = 1, ## Audio class
    LIBUSB_CLASS_COMM = 2, ## Communications class
    LIBUSB_CLASS_HID = 3, ## Human Interface Device class
    LIBUSB_CLASS_PHYSICAL = 5, ## Physical
    LIBUSB_CLASS_IMAGE = 6, ## Image class
    LIBUSB_CLASS_PRINTER = 7, ## Printer class
    LIBUSB_CLASS_MASS_STORAGE = 8, ## Image class
    LIBUSB_CLASS_HUB = 9, ## Hub class
    LIBUSB_CLASS_DATA = 10, ## Data class
    LIBUSB_CLASS_SMART_CARD = 0x0000000B, ## Smart Card
    LIBUSB_CLASS_CONTENT_SECURITY = 0x0000000D, ## Content Security
    LIBUSB_CLASS_VIDEO = 0x0000000E, ## Video
    LIBUSB_CLASS_PERSONAL_HEALTHCARE = 0x0000000F, ## Personal Healthcare
    LIBUSB_CLASS_DIAGNOSTIC_DEVICE = 0x000000DC, ## Diagnostic Device
    LIBUSB_CLASS_WIRELESS = 0x000000E0, ## Wireless class
    LIBUSB_CLASS_APPLICATION = 0x000000FE, ## Application class
    LIBUSB_CLASS_VENDOR_SPEC = 0x000000FF ## Class is vendor-specific

  libusb_descriptor_type* = enum ## \
    ## Enumerates device descriptor types.
    LIBUSB_DT_DEVICE = 0x00000001, ## Device descriptor (see `libusb_device_descriptor`)
    LIBUSB_DT_CONFIG = 0x00000002, ## Configuration descriptor (see `libusb_config_descriptor`)
    LIBUSB_DT_STRING = 0x00000003, ## String descriptor
    LIBUSB_DT_INTERFACE = 0x00000004, ## Interface descriptor. See libusb_interface_descriptor
    LIBUSB_DT_ENDPOINT = 0x00000005, ## Endpoint descriptor. See libusb_endpoint_descriptor
    LIBUSB_DT_BOS = 0x0000000F, ## BOS descriptor
    LIBUSB_DT_DEVICE_CAPABILITY = 0x00000010, ## Device Capability descriptor
    LIBUSB_DT_HID = 0x00000021, ## HID descriptor
    LIBUSB_DT_REPORT = 0x00000022, ## HID report descriptor
    LIBUSB_DT_PHYSICAL = 0x00000023, ## Physical descriptor
    LIBUSB_DT_HUB = 0x00000029, ## Hub descriptor
    LIBUSB_DT_SUPERSPEED_HUB = 0x0000002A, ## SuperSpeed Hub descriptor
    LIBUSB_DT_SS_ENDPOINT_COMPANION = 0x00000030 ## SuperSpeed Endpoint Companion descriptor


const
  # Descriptor sizes per descriptor type
  LIBUSB_DT_DEVICE_SIZE* = 18
  LIBUSB_DT_CONFIG_SIZE* = 9
  LIBUSB_DT_INTERFACE_SIZE* = 9
  LIBUSB_DT_ENDPOINT_SIZE* = 7
  LIBUSB_DT_ENDPOINT_AUDIO_SIZE* = 9
  LIBUSB_DT_HUB_NONVAR_SIZE* = 7
  LIBUSB_DT_SS_ENDPOINT_COMPANION_SIZE* = 6
  LIBUSB_DT_BOS_SIZE* = 5
  LIBUSB_DT_DEVICE_CAPABILITY_SIZE* = 3


  # BOS descriptor sizes
  LIBUSB_BT_USB_2_0_EXTENSION_SIZE* = 7
  LIBUSB_BT_SS_USB_DEVICE_CAPABILITY_SIZE* = 10
  LIBUSB_BT_CONTAINER_ID_SIZE* = 20


  # We unwrap the BOS => define its max size
  LIBUSB_DT_BOS_MAX_SIZE* = ((LIBUSB_DT_BOS_SIZE) +
    (LIBUSB_BT_USB_2_0_EXTENSION_SIZE) +
    (LIBUSB_BT_SS_USB_DEVICE_CAPABILITY_SIZE) +
    (LIBUSB_BT_CONTAINER_ID_SIZE))
  LIBUSB_ENDPOINT_ADDRESS_MASK* = 0x0000000F
  LIBUSB_ENDPOINT_DIR_MASK* = 0x00000080


type
  libusb_endpoint_direction* = enum ## \
    ## Enumerates available endpoint directions
    ## (bit 7 of the libusb_endpoint_descriptor.bEndpointAddress scheme)
    LIBUSB_ENDPOINT_OUT = 0x00000000, ## In: device-to-host
    LIBUSB_ENDPOINT_IN = 0x00000080 ## Out: host-to-device


const
  LIBUSB_TRANSFER_TYPE_MASK* = 0x00000003 ## in bmAttributes


type
  libusb_transfer_type* = enum ## \
    ## Enumerates endpoint transfer types.
    LIBUSB_TRANSFER_TYPE_CONTROL = 0, # Control endpoint
    LIBUSB_TRANSFER_TYPE_ISOCHRONOUS = 1, ## Isochronous endpoint
    LIBUSB_TRANSFER_TYPE_BULK = 2, ## Bulk endpoint
    LIBUSB_TRANSFER_TYPE_INTERRUPT = 3, ## Interrupt endpoint
    LIBUSB_TRANSFER_TYPE_BULK_STREAM = 4 ## Stream endpoint


  libusb_standard_request* = enum ## \
    ## Enumerates standard requests as defined in table 9-5 of the USB 3.0 spec.
    LIBUSB_REQUEST_GET_STATUS = 0x00000000, ## Request status of the specific recipient
    LIBUSB_REQUEST_CLEAR_FEATURE = 0x00000001, ## Clear or disable a specific feature
    LIBUSB_REQUEST_RESERVED2 = 0x00000002, ## Reserved for future use
    LIBUSB_REQUEST_SET_FEATURE = 0x00000003, ## Set or enable a specific feature
    LIBUSB_REQUEST_RESERVED4 = 0x00000004 ## Reserved for future use
    LIBUSB_REQUEST_SET_ADDRESS = 0x00000005, ## Set device address for all future accesses
    LIBUSB_REQUEST_GET_DESCRIPTOR = 0x00000006, ## Get the specified descriptor
    LIBUSB_REQUEST_SET_DESCRIPTOR = 0x00000007, ## Used to update existing
      ## descriptors or add new descriptors
    LIBUSB_REQUEST_GET_CONFIGURATION = 0x00000008, ## Get the current device
      ## configuration value
    LIBUSB_REQUEST_SET_CONFIGURATION = 0x00000009, ## Set device configuration
    LIBUSB_REQUEST_GET_INTERFACE = 0x0000000A, ## Return the selected alternate
      ## setting for the specified interface
    LIBUSB_REQUEST_SET_INTERFACE = 0x0000000B, ## Select an alternate interface
      ## for the specified interface
    LIBUSB_REQUEST_SYNCH_FRAME = 0x0000000C, ## Set then report an endpoint's
      ## synchronization frame
    LIBUSB_REQUEST_SET_SEL = 0x00000030, ## Sets both the U1 and U2 Exit Latency
    LIBUSB_SET_ISOCH_DELAY = 0x00000031 ## Delay from the time a host transmits
      ## a packet to the time it is received by the device.


  libusb_request_type* = enum ## \
    ## Enumerates standard requests, as defined in table 9-5 of the USB 3.0 spec.
    LIBUSB_REQUEST_TYPE_STANDARD = (0x00000000 shl 5), ## Standard
    LIBUSB_REQUEST_TYPE_CLASS = (0x00000001 shl 5), ## Class
    LIBUSB_REQUEST_TYPE_VENDOR = (0x00000002 shl 5), ## Vendor
    LIBUSB_REQUEST_TYPE_RESERVED = (0x00000003 shl 5) ## Reserved


  libusb_request_recipient* = enum ## \
    ## Enumerates recipient bits in the libusb_control_setup.bmRequestType field.
    ## Values 4 through 31 are reserved.
    LIBUSB_RECIPIENT_DEVICE = 0x00000000, ## Device
    LIBUSB_RECIPIENT_INTERFACE = 0x00000001, ## Interface
    LIBUSB_RECIPIENT_ENDPOINT = 0x00000002, ## Endpoint
    LIBUSB_RECIPIENT_OTHER = 0x00000003 ## Other

const
  LIBUSB_ISO_SYNC_TYPE_MASK* = 0x0000000C


type
  libusb_iso_sync_type* = enum ## \
    ## Enumerates synchronization types for isochronous endpoints.
    LIBUSB_ISO_SYNC_TYPE_NONE = 0, ## No synchronization
    LIBUSB_ISO_SYNC_TYPE_ASYNC = 1, ## Asynchronous
    LIBUSB_ISO_SYNC_TYPE_ADAPTIVE = 2, ## Adaptive
    LIBUSB_ISO_SYNC_TYPE_SYNC = 3 ## Synchronous

const
  LIBUSB_ISO_USAGE_TYPE_MASK* = 0x00000030


type
  libusb_iso_usage_type* = enum ## \
    ## Enumerates usage types for isochronous endpoints.
    LIBUSB_ISO_USAGE_TYPE_DATA = 0, ## Data endpoint
    LIBUSB_ISO_USAGE_TYPE_FEEDBACK = 1, ## Feedback endpoint
    LIBUSB_ISO_USAGE_TYPE_IMPLICIT = 2 ## Implicit feedback Data endpoint


type
  libusb_device_descriptor* = object
    ## Standard USB device descriptor. This descriptor is documented in section
    ## 9.6.1 of the USB 3.0 specification. All multiple-byte fields are
    ## represented in host-endian format.
    bLength*: uint8 ## Size of this descriptor (in bytes)
    bDescriptorType*: uint8 ## Descriptor type (LIBUSB_DT_DEVICE).
    bcdUSB*: uint16 ## USB specification release number in binary-coded decimal.
      ## A value of 0x0200 indicates USB 2.0, 0x0110 indicates USB 1.1, etc.
    bDeviceClass*: uint8 ## USB-IF class code for the device.
      ## See `libusb_class_code`.
    bDeviceSubClass*: uint8 ## USB-IF subclass code for the device, qualified by
      ## the bDeviceClass value.
    bDeviceProtocol*: uint8 ## USB-IF protocol code for the device, qualified by
      ## the bDeviceClass and bDeviceSubClass values.
    bMaxPacketSize0*: uint8 ## Maximum packet size for endpoint 0
    idVendor*: uint16 ## USB-IF vendor ID
    idProduct*: uint16 ## USB-IF product ID
    bcdDevice*: uint16 ## Device release number in binary-coded decimal
    iManufacturer*: uint8 ## Index of string descriptor describing manufacturer
    iProduct*: uint8 ## Index of string descriptor describing product
    iSerialNumber*: uint8 ## Index of string descriptor containing device serial number
    bNumConfigurations*: uint8 ## Number of possible configurations


  libusb_endpoint_descriptor* = object
    ## Standard USB endpoint descriptor. This descriptor is documented in
    ## section 9.6.6 of the USB 3.0 specification. All multiple-byte fields are
    ## represented in host-endian format.
    bLength*: uint8 ## Size of this descriptor (in bytes).
    bDescriptorType*: uint8 ## Descriptor type (LIBUSB_DT_ENDPOINT).
    bEndpointAddress*: uint8 ## The address of the endpoint described by this
      ## descriptor. Bits 0:3 are the endpoint number. Bits 4:6 are reserved.
      ## Bit 7 indicates direction, see `libusb_endpoint_direction`.
    bmAttributes*: uint8 ## Attributes which apply to the endpoint when it is
      ## configured using the bConfigurationValue. Bits 0:1 determine the
      ## transfer type and correspond to `libusb_transfer_type`. Bits 2:3 are
      ## only used for isochronous endpoints and correspond to
      ## `libusb_iso_sync_type`. Bits 4:5 are also only used for isochronous
      ## endpoints and correspond to `libusb_iso_usage_type1`. Bits 6:7 are
      ## reserved.
    wMaxPacketSize*: uint16 ## Maximum packet size this endpoint is capable of sending/receiving.
    bInterval*: uint8 ## Interval for polling endpoint for data transfers.
    bRefresh*: uint8 ## For audio devices only: the rate at which synchronization feedback is provided.
    bSynchAddress*: uint8 ## For audio devices only: the address if the synch endpoint
    extra*: ptr cuchar ## Extra descriptors. If libusb encounters unknown
      ## endpoint descriptors, it will store them here, should you wish to parse
      ## them.
    extra_length*: cint ## Length of the extra descriptors, in bytes


  libusb_interface_descriptor* = object 
    bLength*: uint8 #* Size of this descriptor (in bytes) 
    bDescriptorType*: uint8 ## Descriptor type (LIBUSB_DT_INTERFACE).
    bInterfaceNumber*: uint8 ## Number of this interface.
    bAlternateSetting*: uint8 ## Value used to select this alternate setting for
      ## this interface
    bNumEndpoints*: uint8 ## Number of endpoints used by this interface
      ## (excluding the control endpoint).
    bInterfaceClass*: uint8 ## USB-IF class code for this interface
      ## (see `libusb_class_code`)
    bInterfaceSubClass*: uint8 ## USB-IF subclass code for this interface,
      ## qualified by the bInterfaceClass value.
    bInterfaceProtocol*: uint8 ## USB-IF protocol code for this interface,
      ## qualified by the bInterfaceClass and bInterfaceSubClass values.
    iInterface*: uint8 ## Index of string descriptor describing this interface.
    endpoint*: ptr libusb_endpoint_descriptor ## Array of endpoint descriptors.
      ## This length of this array is determined by the bNumEndpoints field.
    extra*: ptr cuchar # Extra descriptors. If libusb encounters unknown
      ## interface descriptors, it will store them here, should you wish to
      ## parse them.
    extra_length*: cint ## Length of the extra descriptors, in bytes.


  libusb_interface* = object
    ## Collection of alternate settings for a particular USB interface.
    altsetting*: ptr libusb_interface_descriptor ## Array of interface
      ## descriptors. The length of this array is determined by the
      ## `num_altsetting` field.
    num_altsetting*: cint ## The number of alternate settings that belong to
      ## this interface.


  libusb_config_descriptor* = object
    bLength*: uint8 ## Size of this descriptor (in bytes) 
    bDescriptorType*: uint8 ## Descriptor type (LIBUSB_DT_CONFIG).
    wTotalLength*: uint16 ## Total length of data returned for this configuration.
    bNumInterfaces*: uint8 ## Number of interfaces supported by this configuration.
    bConfigurationValue*: uint8 ## Identifier value for this configuration.
    iConfiguration*: uint8 ## Index of string descriptor describing this configuration.
    bmAttributes*: uint8 ## Configuration characteristics
    MaxPower*: uint8 ## Maximum power consumption of the USB device from this
      ## bus in this configuration when the device is fully opreation.
      ## Expressed in units of 2 mA.
    interfaces*: ptr libusb_interface ## Array of interfaces supported by this
      ## configuration. The length of this array is determined by the
      ## `bNumInterfaces` field.
    extra*: ptr cuchar ## Extra descriptors. If libusb encounters unknown
      ## configuration descriptors, it will store them here, should you wish to
      ## parse them.
    extra_length*: cint ## Length of the extra descriptors, in bytes.


  libusb_ss_endpoint_companion_descriptor* = object
    bLength*: uint8 ## Size of this descriptor.
    bDescriptorType*: uint8 ## Descriptor type (LIBUSB_DT_SS_ENDPOINT_COMPANION).
    bMaxBurst*: uint8 ## The maximum number of packets the endpoint can send or
      ## recieve as part of a burst.
    bmAttributes*: uint8 ## In bulk EP: bits 4:0 represents the maximum number
      ## of streams the EP supports. In isochronous EP: bits 1:0 represents the
      ## Mult - a zero based value that determines the maximum number of packets
      ## within a service interval.
    wBytesPerInterval*: uint16 ## The total number of bytes this EP will
      ## transfer every service interval. valid only for periodic EPs.


  libusb_bos_dev_capability_descriptor* = object
    ## Generic representation of a BOS Device Capability descriptor. It is
    ## advised to check bDevCapabilityType and call the matching
    ## `libusb_get_*_descriptor` function to get a structure fully matching
    ## the type.
    bLength*: uint8 ## Size of this descriptor (in bytes) 
    bDescriptorType*: uint8 ## Descriptor type (LIBUSB_DT_DEVICE_CAPABILITY).
    bDevCapabilityType*: uint8 ## Device Capability type.
    dev_capability_data*: array[0, uint8] ## Device Capability data (bLength - 3 bytes).


  libusb_bos_descriptor* = object
    ## Binary Device Object Store (BOS) descriptor. This descriptor is
    ## documented in section 9.6.2 of the USB 3.0 specification.
    ## All multiple-byte fields are represented in host-endian format.
    bLength*: uint8 ## Size of this descriptor (in bytes) 
    bDescriptorType*: uint8 ## Descriptor type (LIBUSB_DT_BOS).
    wTotalLength*: uint16 ## Length of this descriptor and all of its sub descriptors.
    bNumDeviceCaps*: uint8 ## The number of separate device capability
      ## descriptors in the BOS.
    dev_capability*: array[0, ptr libusb_bos_dev_capability_descriptor] ## \
      ## `bNumDeviceCap` Device Capability Descriptors.


  libusb_usb_2_0_extension_descriptor* = object
    ## USB 2.0 Extension descriptor. This descriptor is documented in section
    ## 9.6.2.1 of the USB 3.0 specification. All multiple-byte fields are
    ## represented in host-endian format.
    bLength*: uint8 ## Size of this descriptor (in bytes).
    bDescriptorType*: uint8 ## Descriptor type (LIBUSB_DT_DEVICE_CAPABILITY).
    bDevCapabilityType*: uint8 ## Capability type (LIBUSB_BT_USB_2_0_EXTENSION).
    bmAttributes*: uint32 ## Bitmap encoding of supported device level features.
      ## A value of one in a bit location indicates a feature is supported; a
      ## value of zero indicates it is not supported.
      ## See `libusb_usb_2_0_extension_attributes`.


  libusb_ss_usb_device_capability_descriptor* = object
    ## Container ID descriptor. This descriptor is documented in section 9.6.2.3
    ## of the USB 3.0 specification. All multiple-byte fields, except UUIDs, are
    ## represented in host-endian format.
    bLength*: uint8  ## Size of this descriptor (in bytes).
    bDescriptorType*: uint8 ## Descriptor type (LIBUSB_DT_DEVICE_CAPABILITY).
    bDevCapabilityType*: uint8 ## Capability type (LIBUSB_BT_SS_USB_DEVICE_CAPABILITY).
    bmAttributes*: uint8 ## Bitmap encoding of supported device level features.
      ## A value of one in a bit location indicates a feature is supported; a
      ## value of zero indicates it is not supported.
      ## See `libusb_ss_usb_device_capability_attributes`.
    wSpeedSupported*: uint16 ## Bitmap encoding of the speed supported by this
      ## device when operating in SuperSpeed mode. See `libusb_supported_speed`.
    bFunctionalitySupport*: uint8_t ## The lowest speed at which all the
      ## functionality supported by the device is available to the user.
      ## For example if the device supports all its functionality when connected
      ## at full speed and above then it sets this value to 1.
    bU1DevExitLat*: uint8_t ## U1 Device Exit Latency.
    bU2DevExitLat*: uint16_t ## U2 Device Exit Latency.


  libusb_container_id_descriptor* = object
    bLength*: uint8 ## Size of this descriptor (in bytes).
    bDescriptorType*: uint8 ## Descriptor type (LIBUSB_DT_DEVICE_CAPABILITY).
    bDevCapabilityType*: uint8_t ## Capability type (LIBUSB_BT_CONTAINER_ID).
    bReserved*: uint8 ## Reserved for future use.
    ContainerID*: array[16, uint8] ## 128 bit UUID.


  libusb_control_setup* = object
    ## Setup packet for control transfers.
    bmRequestType*: uint8_t ## Request type. Bits 0:4 determine recipient, see
      ## `libusb_request_recipient`. Bits 5:6 determine type, see
      ## `libusb_request_type`. Bit 7 determines data transfer direction, see
      ## `libusb_endpoint_direction`.
    bRequest*: uint8 ## Request. If the type bits of `bmRequestType` are equal
      ## to `LIBUSB_REQUEST_TYPE_STANDARD` then this field refers to
      ## `libusb_standard_request`. For other cases, use of this field is
      ## application-specific.
    wValue*: uint16t ## Value. Varies according to request.
    wIndex*: uint16 ## Index. Varies according to request, typically used to
      ## pass an index or offset
    wLength*: uint16 ## Number of bytes to transfer.


  libusb_version* = object
    ## Provides the version of the libusb runtime.
    major*: uint16 ## Library major version.
    minor*: uint16 ## Library minor version.
    micro*: uint16 ## Library micro version.
    nano*: uint16 ## Library nano version.
    rc*: cstring ## Library release candidate suffix string, e.g. "-rc4".
    describe*: cstring ## For ABI compatibility only.


type
  libusb_speed* = enum ## \
    ## Enumerates speed codes to indicate the speed of devices.
    LIBUSB_SPEED_UNKNOWN = 0, ## The OS doesn't report or know the device speed.
    LIBUSB_SPEED_LOW = 1, ## The device is operating at low speed (1.5MBit/s).
    LIBUSB_SPEED_FULL = 2, ## The device is operating at full speed (12MBit/s).
    LIBUSB_SPEED_HIGH = 3, ## The device is operating at high speed (480MBit/s).
    LIBUSB_SPEED_SUPER = 4 ##The device is operating at super speed (5000MBit/s).


  libusb_supported_speed* = enum ## \
    ## Enumerates supported speeds in the `wSpeedSupported` bit field.
    LIBUSB_LOW_SPEED_OPERATION = 1, ## Low speed operation supported (1.5MBit/s).
    LIBUSB_FULL_SPEED_OPERATION = 2, ## Full speed operation supported (12MBit/s).
    LIBUSB_HIGH_SPEED_OPERATION = 4, ## High speed operation supported (480MBit/s).
    LIBUSB_SUPER_SPEED_OPERATION = 8 ## Superspeed operation supported (5000MBit/s).


  libusb_usb_2_0_extension_attributes* = enum ## \
    ## Masks for the bits of the
    ## `libusb_usb_2_0_extension_descriptor.bmAttributes` field.
    LIBUSB_BM_LPM_SUPPORT = 2 ## Supports Link Power Management (LPM).


  libusb_ss_usb_device_capability_attributes* = enum ## \
    ## Masks for the bits of the
    ## `libusb_ss_usb_device_capability_descriptor.bmAttributes` field.
    LIBUSB_BM_LTM_SUPPORT = 2 ## Supports Latency Tolerance Messages (LTM).


  libusb_bos_type* = enum ## \
    ## Enumerates USB capability types.
    LIBUSB_BT_WIRELESS_USB_DEVICE_CAPABILITY = 1, ## Wireless USB device capability.
    LIBUSB_BT_USB_2_0_EXTENSION = 2, ## USB 2.0 extensions.
    LIBUSB_BT_SS_USB_DEVICE_CAPABILITY = 3, ## SuperSpeed USB device capability.
    LIBUSB_BT_CONTAINER_ID = 4 ## Container ID type.

  libusb_error* = enum ## \
    LIBUSB_ERROR_OTHER = -99, ## Other error.
    LIBUSB_ERROR_NOT_SUPPORTED = -12, ## Operation not supported or unimplemented on this platform.
    LIBUSB_ERROR_NO_MEM = -11, ## Insufficient memory.
    LIBUSB_ERROR_INTERRUPTED = -10, ## System call interrupted (perhaps due to signal) 
    LIBUSB_ERROR_PIPE = -9, ## Pipe error.
    LIBUSB_ERROR_OVERFLOW = -8, ## Overflow.
    LIBUSB_ERROR_TIMEOUT = -7, ## Operation timed out.
    LIBUSB_ERROR_BUSY = -6, ## Resource busy.
    LIBUSB_ERROR_NOT_FOUND = -5, ## Entity not found.
    LIBUSB_ERROR_NO_DEVICE = -4, ## No such device (it may have been disconnected).
    LIBUSB_ERROR_ACCESS = -3, ## Access denied (insufficient permissions)
    LIBUSB_ERROR_INVALID_PARAM = -2, ## Invalid parameter.
    LIBUSB_ERROR_IO = -1, ## Input/output error.
    LIBUSB_SUCCESS = 0 ## Success (no error).

const
  LIBUSB_ERROR_COUNT* = 14 ## Total number of error codes in enum libusb_error.


type 
  libusb_transfer_status* = enum ## \
    ## Enumerats transfer status codes.
    LIBUSB_TRANSFER_COMPLETED, ## Transfer completed without error.
      ## Note that this does not indicate that the entire amount of requested
      ## data was transferred.
    LIBUSB_TRANSFER_ERROR, ## Transfer failed.
    LIBUSB_TRANSFER_TIMED_OUT, ## Transfer timed out.
    LIBUSB_TRANSFER_CANCELLED, ## Transfer was cancelled.
    LIBUSB_TRANSFER_STALL, ## For bulk/interrupt endpoints: halt condition
      ## detected (endpoint stalled). For control endpoints: control request
      ## not supported.
    LIBUSB_TRANSFER_NO_DEVICE, ## Device was disconnected.
    LIBUSB_TRANSFER_OVERFLOW ## Device sent more data than requested.


  libusb_transfer_flags* = enum ## \
    ## Enumerates `libusb_transfer.flags` values.
    LIBUSB_TRANSFER_SHORT_NOT_OK = 1 shl 0, ## Report short frames as errors.
    LIBUSB_TRANSFER_FREE_BUFFER = 1 shl 1, ## Automatically `free()` transfer
      ## buffer during `libusb_free_transfer()`
    LIBUSB_TRANSFER_FREE_TRANSFER = 1 shl 2, ## Automatically call
      ## `libusb_free_transfer()` after callback returns. If this flag is set,
      ## it is illegal to call `libusb_free_transfer()` from your transfer
      ## callback, as this will result in a double-free when this flag is acted
      ## upon.
    LIBUSB_TRANSFER_ADD_ZERO_PACKET = 1 shl 3 ## Terminate transfers that are a
      ## multiple of the endpoint's wMaxPacketSize with an extra zero length
      ## packet. This is useful when a device protocol mandates that each
      ## logical request is terminated by an incomplete packet (i.e. the logical
      ## requests are not separated by other means).
      ##
      ## This flag only affects host-to-device transfers to bulk and interrupt
      ## endpoints. In other situations, it is ignored.
      ##
      ## This flag only affects transfers with a length that is a multiple of 
      ## the endpoint's wMaxPacketSize. On transfers of other lengths, this flag
      ## has no effect. Therefore, if you are working with a device that needs a
      ## ZLP whenever the end of the logical request falls on a packet boundary,
      ## then it is sensible to set this flag on every transfer (you do not have
      ## to worry about only setting it on transfers that end on the boundary).
      ##
      ## This flag is currently only supported on Linux. On other systems,
      ## `libusb_submit_transfer()` will return `LIBUSB_ERROR_NOT_SUPPORTED`
      ## for every transfer where this flag is set.
      ##
      ## Available since libusb-1.0.9


type 
  libusb_iso_packet_descriptor* = object
    ## Isochronous packet descriptor.
    length*: cuint ## Length of data to request in this packet.
    actual_length*: cuint   ## Amount of data that was actually transferred.
    status*: libusb_transfer_status ## Status code for this packet.


  libusb_transfer* = object
    ## Generic USB transfer structure. The user populates this structure and
    ## then submits it in order to request a transfer. After the transfer has
    ## completed, the library populates the transfer with the results and passes
    ## it back to the user.
    dev_handle*: ptr libusb_device_handle ## Handle of the device that this
      ## transfer will be submitted to.
    flags*: uint8 ## A bitwise OR combination of `libusb_transfer_flags`.
    endpoint*: cuchar ## Address of the endpoint where this transfer will be sent.
    `type`*: cuchar ## Type of the endpoint from \ref libusb_transfer_type.
    timeout*: cuint ## Timeout for this transfer in millseconds. A value of 0
      ## indicates no timeout.
    status*: libusb_transfer_status ## The status of the transfer. Read-only,
      ## and only for use within transfer callback function.
      ##
      ## If this is an isochronous transfer, this field may read COMPLETED even
      ## if there were errors in the frames. Use the
      ## `libusb_iso_packet_descriptor.status` field in each packet to determine
      ## if errors occurred.
    length*: cint ## Length of the data buffer.
    actual_length*: cint ## Actual length of data that was transferred.
      ## Read-only, and only for use within transfer callback function.
      ## Not valid for isochronous endpoint transfers.
    callback*: libusb_transfer_cb_fn ## Callback function. This will be invoked
      ## when the transfer completes, fails, or is cancelled.
      ## TODO: convert this to Nim
    user_data*: pointer ## User context data to pass to the callback function.
    buffer*: ptr cuchar ## Data buffer.
    num_iso_packets*: cint ## Number of isochronous packets. Only used for I/O
      ## with isochronous endpoints.
    iso_packet_desc*: array[0, libusb_iso_packet_descriptor] ## Isochronous
      ## packet descriptors, for isochronous transfers only.









































