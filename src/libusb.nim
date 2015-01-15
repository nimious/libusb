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
    `type`*: cuchar ## Type of the endpoint from `libusb_transfer_type`.
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


type 
  libusb_capability* = enum ## \
    ## Enumerates capabilities supported by an instance of libusb on the current
    ## running platform. Test if the loaded library supports a given capability
    ## by calling `libusb_has_capability()`.
    LIBUSB_CAP_HAS_CAPABILITY = 0x00000000, ## The libusb_has_capability() API
      ## is available.
    LIBUSB_CAP_HAS_HOTPLUG = 0x00000001, ## Hotplug support is available on this
      ## platform.
    LIBUSB_CAP_HAS_HID_ACCESS = 0x00000100, ## The library can access HID
      ## devices without requiring user intervention. Note that before being
      ## able to actually access an HID device, you may still have to call
      ## additional libusb functions such as `libusb_detach_kernel_driver()`.
    LIBUSB_CAP_SUPPORTS_DETACH_KERNEL_DRIVER = 0x00000101 ## The library
      ## supports detaching of the default USB driver, using
      ## `libusb_detach_kernel_driver()`, if one is set by the OS kernel.


  libusb_log_level* = enum ## \
    ## Enumerates log message levels.
    LIBUSB_LOG_LEVEL_NONE = 0, ## No messages ever printed by the library (default)
    LIBUSB_LOG_LEVEL_ERROR, ## Error messages are printed to stderr
    LIBUSB_LOG_LEVEL_WARNING, ## Warning and error messages are printed to stderr
    LIBUSB_LOG_LEVEL_INFO, ## Informational messages are printed to stdout,
      ## warning and error messages are printed to stderr
    LIBUSB_LOG_LEVEL_DEBUG ## Debug and informational messages are printed to
      ## stdout, warnings and errors to stderr


proc libusb_init*(ctx: ptr ptr libusb_context): cint
  {.cdecl, dynlib: dllname, importc: "libusb_init".}
  ## Initializes libusb.
  ##
  ## This function must be called before calling any other libusb function.
  ## If you do not provide an output location for a context pointer, a default
  ## context will be created. If there was already a default context, it will be
  ## reused (and nothing will be initialized/reinitialized).
  ##
  ## - ``context`` - Optional output location for context pointer. Only valid on
  ##    return code 0.
  ##
  ## ``Returns`` 0 on success, or a LIBUSB_ERROR code on failure.


proc libusb_exit*(ctx: ptr libusb_context)
  {.cdecl, dynlib: dllname, importc: "libusb_exit".}
  ## Shuts down libusb.
  ##
  ## Should be called after closing all open devices and before your application
  ## terminates.
  ##
  ## - ``ctx`` - The context to deinitialize, or nil for the default context.


proc libusb_set_debug*(ctx: ptr libusb_context; level: cint)
  {.cdecl, dynlib: dllname, importc: "libusb_set_debug".}
  ## Sets the log message verbosity.
  ##
  ## The default level is LIBUSB_LOG_LEVEL_NONE, which means no messages are
  ## ever printed. If you choose to increase the message verbosity level, ensure
  ## that your application does not close the stdout/stderr file descriptors.
  ##
  ## You are advised to use level LIBUSB_LOG_LEVEL_WARNING. libusb is
  ## conservative with its message logging and most of the time, will only log
  ## messages that explain error conditions and other oddities. This will help
  ## you debug your software.
  ##
  ## If the LIBUSB_DEBUG environment variable was set when libusb was
  ## initialized, this function does nothing: the message verbosity is fixed to
  ## the value in the environment variable.
  ##
  ## If libusb was compiled without any message logging, this function does
  ## nothing: you'll never get any messages. If libusb was compiled with verbose
  ## debug message logging, this function does nothing: you'll always get
  ## messages from all levels.
  ##
  ## - ``ctx`` - The context to operate on, or NULL for the default context
  ## - ``level`` - The debug level to set.


proc libusb_get_version*(): ptr libusb_version
  {.cdecl, dynlib: dllname, importc: "libusb_get_version".}
  ## Gets the version (major, minor, micro, nano and rc) of the running library.
  ##
  ## ``Returns`` An object containing the version number.


proc libusb_has_capability*(capability: uint32_t): cint
  {.cdecl, dynlib: dllname, importc: "libusb_has_capability".}
  ## Checks at runtime if the loaded library has a given capability.
  ##
  ## This call should be performed after `libusb_init()`, to ensure the
  ## backend has updated its capability set.
  ##
  ## - ``capability`` - The libusb_capability to check for.
  ##
  ## ``Returns`` nonzero if the running library has the capability, 0 otherwise.


proc libusb_error_name*(errcode: cint): cstring
  {.cdecl, dynlib: dllname, importc: "libusb_error_name".}
  ## Gets a constant NULL-terminated string with the ASCII name of a libusb
  ## error or transfer status code.
  ##
  ## The caller must not free the returned string.
  ##
  ## - ``error_code`` - The libusb_error or libusb_transfer_status code to
  ##    return the name of.
  ##
  ## ``Returns`` the error name, or the string UNKNOWN if the value of
  ##    error_code is not a known error / status code.


proc libusb_setlocale*(locale: cstring): cint
  {.cdecl, dynlib: dllname, importc: "libusb_setlocale".}
  ## Sets the language, and only the language, not the encoding! used for
  ## translatable libusb messages.
  ##
  ## This takes a locale string in the default setlocale format: lang[-region]
  ## or lang[_country_region][.codeset]. Only the lang part of the string is
  ## used, and only 2 letter ISO 639-1 codes are accepted for it, such as "de".
  ## The optional region, country_region or codeset parts are ignored. This
  ## means that functions which return translatable strings will NOT honor the
  ## specified encoding. All strings returned are encoded as UTF-8 strings.
  ##
  ## If `libusb_setlocale()` is not called, all messages will be in English.
  ##
  ## The following functions return translatable strings:
  ##    - `libusb_strerror()`
  ##
  ## Note that the libusb log messages controlled through `libusb_set_debug()`
  ## are not translated, they are always in English.
  ##
  ## For POSIX UTF-8 environments if you want libusb to follow the standard
  ## locale settings, call libusb_setlocale(setlocale(LC_MESSAGES, nil)),
  ## after your app has done its locale setup.
  ##
  ## ``locale`` - The locale-string in the form of
  ##    lang[_country_region][.codeset] or lang[-region], where lang is a 2
  ##    letter ISO 639-1 code.
  ##
  ## ``Returns``
  ##    - LIBUSB_SUCCESS on success
  ##    - LIBUSB_ERROR_INVALID_PARAM if the locale doesn't meet the requirements
  ##    - LIBUSB_ERROR_NOT_FOUND if the requested language is not supported
  ##    - LIBUSB_ERROR code on other errors.


proc libusb_strerror*(errcode: libusb_error): cstring
  {.cdecl, dynlib: dllname, importc: "libusb_strerror".}
  ## Gets a constant string with a short description of the given error code.
  ## this description is intended for displaying to the end user and will be in
  ## the language set by `libusb_setlocale()`.
  ##
  ## The returned string is encoded in UTF-8. The messages always start with a
  ## capital letter and end without any dot. The caller must not free() the
  ## returned string.
  ##
  ## ``errcode`` - The error code whose description is desired.
  ##
  ## ``Returns`` a short description of the error code in UTF-8 encoding.


proc libusb_get_device_list*(ctx: ptr libusb_context; 
  list: ptr ptr ptr libusb_device): ssize_t
  {.cdecl, dynlib: dllname, importc: "libusb_get_device_list".}
  ## Gets a list of USB devices currently attached to the system.
  ##
  ## This is your entry point into finding a USB device to operate. You are
  ## expected to unreference all the devices when you are done with them, and
  ## then free the list with `libusb_free_device_list()`.
  ##
  ## Note that `libusb_free_device_list()` can unref all the devices for you.
  ## Be careful not to unreference a device you are about to open until after
  ## you have opened it.
  ##
  ## The return value of this function indicates the number of devices in the
  ## resultant list. The list is actually one element larger, as it is
  ## NULL-terminated.
  ##
  ## ``ctx`` - The context to operate on, or nil for the default context.
  ## ``list`` - The output location for a list of devices. Must be later freed
  ##    with `libusb_free_device_list()`.
  ##
  ## ``Returns`` the number of devices in the outputted list, or any
  ## `libusb_error` according to errors encountered by the backend.


proc libusb_free_device_list*(list: ptr ptr libusb_device; unref_devices: cint)
  {.cdecl, dynlib: dllname, importc: "libusb_free_device_list".}
  ## Frees a list of devices previously discovered using
  ## `libusb_get_device_list()`.
  ##
  ## If the `unref_devices parameter` is set, the reference count of each device
  ## in the list is decremented by 1.
  ##
  ## ``list`` - The list to free
  ## ``unref_devices`` - Whether to unref the devices in the list.


proc libusb_ref_device*(dev: ptr libusb_device): ptr libusb_device
  {.cdecl, dynlib: dllname, importc: "libusb_ref_device".}
  ## Increments the reference count of a device.
  ##
  ## ``dev`` - The device to reference.
  ##
  ## ``Returns`` the same device.


proc libusb_unref_device*(dev: ptr libusb_device)
  {.cdecl, dynlib: dllname, importc: "libusb_unref_device".}
  ## Decrement the reference count of a device.
  ##
  ## If the decrement operation causes the reference count to reach zero, the
  ## device shall be destroyed.
  ##
  ## ``dev`` - The device to unreference.


proc libusb_get_configuration*(dev: ptr libusb_device_handle; config: ptr cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_configuration".}
  ## Determines the bConfigurationValue of the currently active configuration.
  ##
  ## You could formulate your own control request to obtain this information,
  ## but this function has the advantage that it may be able to retrieve the
  ## information from operating system caches (no I/O involved).
  ##
  ## If the OS does not cache this information, then this function will block
  ## while a control transfer is submitted to retrieve the information. This
  ## function will return a value of 0 in the config output parameter if the
  ## device is in unconfigured state.
  ##
  ## ``dev`` - A device handle.
  ## ``config`` - Output location for the bConfigurationValue of the active
  ##    configuration (only valid for return code 0)
  ##
  ## Returns
  ##    0 on success,
  ##    `LIBUSB_ERROR_NO_DEVICE` if the device has been disconnected,
  ##    `LIBUSB_ERROR` codes for other failures.


proc libusb_get_device_descriptor*(dev: ptr libusb_device;
  desc: ptr libusb_device_descriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_device_descriptor".}
  ## Gets the USB device descriptor for a given device.
  ##
  ## This is a non-blocking function; the device descriptor is cached in memory.
  ## Note since libusb-1.0.16, LIBUSB_API_VERSION >= 0x01000102, this function
  ## always succeeds.
  ##
  ## ``dev`` - The device.
  ## ``desc`` - Output location for the descriptor data.
  ##
  ## Returns 0 on success or a `LIBUSB_ERROR` code on failure.


proc libusb_get_active_config_descriptor*(dev: ptr libusb_device;
  config: ptr ptr libusb_config_descriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_active_config_descriptor".}
  ## Gets the USB configuration descriptor for the currently active configuration.
  ##
  ## This is a non-blocking function which does not involve any requests being
  ## sent to the device.
  ##
  ## ``dev`` - A device
  ## ``config`` - Output location for the USB configuration descriptor. Only
  ##    valid if 0 was returned. Must be freed with
  ##    `libusb_free_config_descriptor()` after use.
  ##
  ## Returns 0 on success,
  ##    `LIBUSB_ERROR_NOT_FOUND` if the device is in unconfigured state,
  ##    `LIBUSB_ERROR` codes for other errors.


proc libusb_get_config_descriptor*(dev: ptr libusb_device;
  config_index: uint8_t; config: ptr ptr libusb_config_descriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_config_descriptor".}
  ## Gets a USB configuration descriptor based on its index.
  ##
  ## This is a non-blocking function which does not involve any requests being
  ## sent to the device.
  ##
  ## ``dev`` - A device.
  ## ``config_index`` - The index of the configuration you wish to retrieve.
  ## ``config`` - Output location for the USB configuration descriptor. Only
  ##    valid if 0 was returned. Must be freed with
  ##    `libusb_free_config_descriptor()` after use.
  ##
  ## Returns 0 on success,
  ##    `LIBUSB_ERROR_NOT_FOUND` if the configuration does not exist,
  ##    `LIBUSB_ERROR` codes for other errors.


proc libusb_get_config_descriptor_by_value*(dev: ptr libusb_device;
  bConfigurationValue: uint8_t; config: ptr ptr libusb_config_descriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_config_descriptor_by_value".}
  ## Gets a USB configuration descriptor with a specific bConfigurationValue.
  ##
  ## This is a non-blocking function which does not involve any requests being
  ## sent to the device.
  ##
  ## ``dev`` - A device.
  ## ``bConfigurationValue`` - The `bConfigurationValue` of the configuration
  ##    you wish to retrieve.
  ## ``config`` - Output location for the USB configuration descriptor. Only
  ##    valid if 0 was returned. Must be freed with
  ##    `libusb_free_config_descriptor()` after use.
  ##
  ## Returns 0 on success,
  ##    `LIBUSB_ERROR_NOT_FOUND` if the configuration does not exist,
  ##    `LIBUSB_ERROR` codes for other errors.


proc libusb_free_config_descriptor*(config: ptr libusb_config_descriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_config_descriptor".}
  ## Frees a configuration descriptor obtained from
  ## `libusb_get_active_config_descriptor() or `libusb_get_config_descriptor()`.
  ##
  ## It is safe to call this function with a nil config parameter, in which
  ## case the function simply returns.
  ##
  ## ``config`` - The configuration descriptor to free.


proc libusb_get_ss_endpoint_companion_descriptor*(ctx: ptr libusb_context;
  endpoint: ptr libusb_endpoint_descriptor;
  ep_comp: ptr ptr libusb_ss_endpoint_companion_descriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_ss_endpoint_companion_descriptor".}
  ## Gets an endpoints superspeed endpoint companion descriptor (if any).
  ##
  ## ``ctx`` - The context to operate on, or nil for the default context.
  ## ``endpoint`` - Endpoint descriptor from which to get the superspeed
  ##    endpoint companion descriptor.
  ## ``ep_comp`` - Output location for the superspeed endpoint companion
  ##    descriptor. Only valid if 0 was returned. Must be freed with
  ## `libusb_free_ss_endpoint_companion_descriptor()` after use.
  ##
  ## Returns 0 on success,
  ##    `LIBUSB_ERROR_NOT_FOUND` if the configuration does not exist,
  ##    `LIBUSB_ERROR` codes for other errors.


proc libusb_free_ss_endpoint_companion_descriptor*(
  ep_comp: ptr libusb_ss_endpoint_companion_descriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_ss_endpoint_companion_descriptor".}
  ## Free a superspeed endpoint companion descriptor obtained from
  ## `libusb_get_ss_endpoint_companion_descriptor()`.
  ##
  ## It is safe to call this function with a nil `ep_comp parameter`, in which case the function simply returns.
  ##
  ## ``ep_comp`` - The superspeed endpoint companion descriptor to free.


proc libusb_get_bos_descriptor*(handle: ptr libusb_device_handle;
  bos: ptr ptr libusb_bos_descriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_bos_descriptor".}
  ## Gets a Binary Object Store (BOS) descriptor This is a BLOCKING function,
  ## which will send requests to the device.
  ##
  ## ``handle`` - The handle of an open libusb device.
  ## ``bos`` - Output location for the BOS descriptor. Only valid if 0 was
  ##    returned. Must be freed with `libusb_free_bos_descriptor()` after use.
  ##
  ## Returns 0 on success,
  ##    `LIBUSB_ERROR_NOT_FOUND` if the device doesn't have a BOS descriptor,
  ##    `LIBUSB_ERROR` codes for other errors.


proc libusb_free_bos_descriptor*(bos: ptr libusb_bos_descriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_bos_descriptor".}
  ## Frees a BOS descriptor obtained from `libusb_get_bos_descriptor()`.
  ##
  ## It is safe to call this function with a nil bos parameter, in which case
  ## the function simply returns.
  ##
  ## ``bos`` - The BOS descriptor to free.


proc libusb_get_usb_2_0_extension_descriptor*(ctx: ptr libusb_context;
  dev_cap: ptr libusb_bos_dev_capability_descriptor;
  usb_2_0_extension: ptr ptr libusb_usb_2_0_extension_descriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_usb_2_0_extension_descriptor".}
  ## Gets an USB 2.0 Extension descriptor.
  ##
  ## ``ctx`` - The context to operate on, or nil for the default context.
  ## ``dev_cap`` - Device Capability descriptor with a bDevCapabilityType of
  ##    `libusb_capability_type.LIBUSB_BT_USB_2_0_EXTENSION`
  ## ``usb_2_0_extension`` - Output location for the USB 2.0 Extension
  ##    descriptor. Only valid if 0 was returned. Must be freed with
  ##    `libusb_free_usb_2_0_extension_descriptor()` after use.
  ##
  ## Returns 0 on success, a LIBUSB_ERROR code on error.


proc libusb_free_usb_2_0_extension_descriptor*(
  usb_2_0_extension: ptr libusb_usb_2_0_extension_descriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_usb_2_0_extension_descriptor".}
  ## Frees a USB 2.0 Extension descriptor obtained from
  ## `libusb_get_usb_2_0_extension_descriptor()`.
  ##
  ## It is safe to call this function with a nil `usb_2_0_extension` parameter,
  ## in which case the function simply returns.
  ##
  ## ``usb_2_0_extension`` - The USB 2.0 Extension descriptor to free.


proc libusb_get_ss_usb_device_capability_descriptor*(ctx: ptr libusb_context;
  dev_cap: ptr libusb_bos_dev_capability_descriptor;
  ss_usb_device_cap: ptr ptr libusb_ss_usb_device_capability_descriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_ss_usb_device_capability_descriptor".}
  ## Gets a SuperSpeed USB Device Capability descriptor.
  ##
  ## ``ctx`` - The context to operate on, or nil for the default context.
  ## ``dev_cap`` - Device Capability descriptor with a `bDevCapabilityType` of
  ##    `libusb_capability_type.LIBUSB_BT_SS_USB_DEVICE_CAPABILITY`
  ## ``ss_usb_device_cap`` - Output location for the SuperSpeed USB Device
  ##    Capability descriptor. Only valid if 0 was returned. Must be freed with
  ##    `libusb_free_ss_usb_device_capability_descriptor()` after use.
  ##
  ## Returns 0 on success, a LIBUSB_ERROR code on error.


proc libusb_free_ss_usb_device_capability_descriptor*(
  ss_usb_device_cap: ptr libusb_ss_usb_device_capability_descriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_ss_usb_device_capability_descriptor".}
  ## Frees a SuperSpeed USB Device Capability descriptor obtained from
  ## `libusb_get_ss_usb_device_capability_descriptor()`.
  ##
  ## It is safe to call this function with a nil `ss_usb_device_cap parameter`,
  ## in which case the function simply returns.
  ##
  ## ``ss_usb_device_cap`` - the USB 2.0 Extension descriptor to free.


proc libusb_get_container_id_descriptor*(ctx: ptr libusb_context;
  dev_cap: ptr libusb_bos_dev_capability_descriptor;
  container_id: ptr ptr libusb_container_id_descriptor): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_container_id_descriptor".}
  ## Gets a Container ID descriptor.
  ##
  ## ``ctx`` - The context to operate on, or nil for the default context.
  ## ``dev_cap`` - Device Capability descriptor with a `bDevCapabilityType` of
  ##    `libusb_capability_type.LIBUSB_BT_CONTAINER_ID`
  ## ``container_id`` - Output location for the Container ID descriptor. Only
  ##    valid if 0 was returned. Must be freed with
  ##    `libusb_free_container_id_descriptor()` after use.
  ##
  ## Returns 0 on success, a LIBUSB_ERROR code on error.


proc libusb_free_container_id_descriptor*(
  container_id: ptr libusb_container_id_descriptor)
  {.cdecl, dynlib: dllname, importc: "libusb_free_container_id_descriptor".}
  ## Frees a Container ID descriptor obtained from
  ## `libusb_get_container_id_descriptor()`.
  ##
  ## It is safe to call this function with a nil `container_id` parameter, in
  ## which case the function simply returns.
  ##
  ## ``container_id`` - The USB 2.0 Extension descriptor to free.


proc libusb_get_bus_number*(dev: ptr libusb_device): uint8
  {.cdecl, dynlib: dllname, importc: "libusb_get_bus_number".}
  ## Gets the number of the bus that a device is connected to.
  ##
  ## ``dev`` - A device.
  ##
  ## Returns the bus number.


proc libusb_get_port_number*(dev: ptr libusb_device): uint8
  {.cdecl, dynlib: dllname, importc: "libusb_get_port_number".}
  ## Get the number of the port that a device is connected to.
  ##
  ## Unless the OS does something funky, or you are hot-plugging USB extension
  ## cards, the port number returned by this call is usually guaranteed to be
  ## uniquely tied to a physical port, meaning that different devices plugged on
  ## the same physical port should return the same port number.
  ##
  ## But outside of this, there is no guarantee that the port number returned by
  ## this call will remain the same, or even match the order in which ports have
  ## been numbered by the HUB/HCD manufacturer.
  ##
  ## ``dev`` - A device.
  ##
  ## Returns the port number (0 if not available).


proc libusb_get_port_numbers*(dev: ptr libusb_device;
  port_numbers: ptr uint8; port_numbers_len: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_port_numbers".}
  ## Get the list of all port numbers from root for the specified device.
  ##
  ## ``dev`` - A device.
  ## ``port_numbers`` - The array that should contain the port numbers.
  ## ``port_numbers_len`` - The maximum length of the array. As per the USB 3.0
  ##    specs, the current maximum limit for the depth is 7.
  ##
  ## Returns the number of elements filled, `LIBUSB_ERROR_OVERFLOW` if the array
  ## is too small.


proc libusb_get_parent*(dev: ptr libusb_device): ptr libusb_device
  {.cdecl, dynlib: dllname, importc: "libusb_get_parent".}

proc libusb_get_device_address*(dev: ptr libusb_device): uint8
  {.cdecl, dynlib: dllname, importc: "libusb_get_device_address".}

proc libusb_get_device_speed*(dev: ptr libusb_device): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_device_speed".}

proc libusb_get_max_packet_size*(dev: ptr libusb_device; endpoint: cuchar): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_max_packet_size".}

proc libusb_get_max_iso_packet_size*(dev: ptr libusb_device; endpoint: cuchar): cint
  {.cdecl, dynlib: dllname, importc: "libusb_get_max_iso_packet_size".}

proc libusb_open*(dev: ptr libusb_device; handle: ptr ptr libusb_device_handle): cint
  {.cdecl, dynlib: dllname, importc: "libusb_open".}

proc libusb_close*(dev_handle: ptr libusb_device_handle)
  {.cdecl, dynlib: dllname, importc: "libusb_close".}

proc libusb_get_device*(dev_handle: ptr libusb_device_handle): ptr libusb_device
  {.cdecl, dynlib: dllname, importc: "libusb_get_device".}

proc libusb_set_configuration*(dev: ptr libusb_device_handle;
  configuration: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_set_configuration".}

proc libusb_claim_interface*(dev: ptr libusb_device_handle;
  interface_number: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_claim_interface".}

proc libusb_release_interface*(dev: ptr libusb_device_handle;
  interface_number: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_release_interface".}

proc libusb_open_device_with_vid_pid*(ctx: ptr libusb_context;
  vendor_id: uint16_t; product_id: uint16_t): ptr libusb_device_handle
  {.cdecl, dynlib: dllname, importc: "libusb_open_device_with_vid_pid".}

proc libusb_set_interface_alt_setting*(dev: ptr libusb_device_handle; 
  interface_number: cint; alternate_setting: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_set_interface_alt_setting".}

proc libusb_clear_halt*(dev: ptr libusb_device_handle; endpoint: cuchar): cint
  {.cdecl, dynlib: dllname, importc: "libusb_clear_halt".}

proc libusb_reset_device*(dev: ptr libusb_device_handle): cint
  {.cdecl, dynlib: dllname, importc: "libusb_reset_device".}

proc libusb_alloc_streams*(dev: ptr libusb_device_handle; 
  num_streams: uint32_t; endpoints: ptr cuchar; num_endpoints: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_alloc_streams".}

proc libusb_free_streams*(dev: ptr libusb_device_handle; 
  endpoints: ptr cuchar; num_endpoints: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_free_streams".}

proc libusb_kernel_driver_active*(dev: ptr libusb_device_handle;
  interface_number: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_kernel_driver_active".}

proc libusb_detach_kernel_driver*(dev: ptr libusb_device_handle; 
  interface_number: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_detach_kernel_driver".}

proc libusb_attach_kernel_driver*(dev: ptr libusb_device_handle;
  interface_number: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_attach_kernel_driver".}

proc libusb_set_auto_detach_kernel_driver*(dev: ptr libusb_device_handle;
  enable: cint): cint
  {.cdecl, dynlib: dllname, importc: "libusb_set_auto_detach_kernel_driver".}


# Async I/O ####################################################################

proc libusb_control_transfer_get_data*(transfer: ptr libusb_transfer):
  ptr cuchar {.inline.} =
  ## Get the data section of a control transfer. This convenience function is here
  ## to remind you that the data does not start until 8 bytes into the actual
  ## buffer, as the setup packet comes first.
  ##
  ## Calling this function only makes sense from a transfer callback function,
  ## or situations where you have already allocated a suitably sized buffer at
  ## transfer->buffer.
  ##
  ## ``transfer`` - A transfer.
  ##
  ## Returns pointer to the first byte of the data section.
  return transfer.buffer + LIBUSB_CONTROL_SETUP_SIZE


proc libusb_control_transfer_get_setup*(transfer: ptr libusb_transfer):
  ptr libusb_control_setup {.inline.} =
  ## Get the control setup packet of a control transfer. This convenience
  ## function is here to remind you that the control setup occupies the first
  ## 8 bytes of the transfer data buffer.
  ##
  ## Calling this function only makes sense from a transfer callback function,
  ## or situations where you have already allocated a suitably sized buffer at
  ## transfer->buffer.
  ##
  ## ``transfer`` - A transfer.
  ##
  ## Returns a casted pointer to the start of the transfer data buffer.
  return cast[ptr libusb_control_setup](cast[pointer](transfer.buffer))


proc libusb_fill_control_setup*(buffer: ptr cuchar; bmRequestType: uint8;
  bRequest: uint8; wValue: uint16; wIndex: uint16; wLength: uint16) {.inline.} =
  ## Helper function to populate the setup packet (first 8 bytes of the data
  ## buffer) for a control transfer. The wIndex, wValue and wLength values should
  ## be given in host-endian byte order.
  ##
  ## ``buffer`` - Buffer to output the setup packet into. This pointer must be
  ##      aligned to at least 2 bytes boundary.
  ## ``bmRequestType`` - See the `bmRequestType` field of `libusb_control_setup`.
  ## ``bRequest`` - See the `bRequest` field of `libusb_control_setup`.
  ## ``wValue`` - See the `wValue` field of `libusb_control_setup`.
  ## ``wIndex`` - See the `wIndex` field of `libusb_control_setup`.
  ## ``wLength`` - See the `wLength` field of `libusb_control_setup`.
  var setup: ptr libusb_control_setup = cast[ptr libusb_control_setup](cast[pointer](buffer))
  setup.bmRequestType = bmRequestType
  setup.bRequest = bRequest
  setup.wValue = libusb_cpu_to_le16(wValue)
  setup.wIndex = libusb_cpu_to_le16(wIndex)
  setup.wLength = libusb_cpu_to_le16(wLength)


proc libusb_alloc_transfer*(iso_packets: cint): ptr libusb_transfer
  ## Allocate a libusb transfer with a specified number of isochronous packet
  ## descriptors.
  ##
  ## The returned transfer is pre-initialized for you. When the new transfer is
  ## no longer needed, it should be freed with `libusb_free_transfer()`.
  ## Transfers intended for non-isochronous endpoints (e.g. control, bulk,
  ## interrupt) should specify an iso_packets count of zero.
  ##
  ## For transfers intended for isochronous endpoints, specify an appropriate
  ## number of packet descriptors to be allocated as part of the transfer. The
  ## returned transfer is not specially initialized for isochronous I/O; you are
  ## still required to set the num_iso_packets and type fields accordingly.
  ##
  ## It is safe to allocate a transfer with some isochronous packets and then
  ## use it on a non-isochronous endpoint. If you do this, ensure that at time
  ## of submission, num_iso_packets is 0 and that type is set appropriately.
  ##
  ## ``iso_packets`` - Number of isochronous packet descriptors to allocate.
  ##
  ## Returns a newly allocated transfer, or nil on error 


proc libusb_submit_transfer*(transfer: ptr libusb_transfer): cint
  ## Submit a transfer.
  ##
  ## This function will fire off the USB transfer and then return immediately.
  ##
  ## ``transfer`` - The transfer to submit.
  ##
  ## Returns
  ##    0 on success,
  ##    `LIBUSB_ERROR_NO_DEVICE` if the device has been disconnected,
  ##    `LIBUSB_ERROR_BUSY` if the transfer has already been submitted,
  ##    `LIBUSB_ERROR_NOT_SUPPORTED` if the transfer flags are not supported by
  ##    the operating system,
  ##    `LIBUSB_ERROR` codes for other failures.


proc libusb_cancel_transfer*(transfer: ptr libusb_transfer): cint
  ## Asynchronously cancel a previously submitted transfer.
  ##
  ## This function returns immediately, but this does not indicate cancellation
  ## is complete. Your callback function will be invoked at some later time with
  ## a transfer status of `LIBUSB_TRANSFER_CANCELLED`.
  ##
  ## ``transfer`` - The transfer to cancel.
  ##
  ## Returns 0 on success,
  ##    `LIBUSB_ERROR_NOT_FOUND` if the transfer is already complete or
  ##    cancelled,
  ##    `LIBUSB_ERROR` codes for other failures.


proc libusb_free_transfer*(transfer: ptr libusb_transfer)
  ## Free a transfer structure.
  ##
  ## This should be called for all transfers allocated with
  ## `libusb_alloc_transfer()`. If the `LIBUSB_TRANSFER_FREE_BUFFER` flag is set
  ## and the transfer buffer is not nil, this function will also free the
  ## transfer buffer using the standard system memory allocator (e.g. free()).
  ##
  ## It is legal to call this function with a nil transfer. In this case, the
  ## function will simply return safely.
  ##
  ## It is not legal to free an active transfer (one which has been submitted
  ## and has not yet completed).
  ##
  ## ``transfer`` - The transfer to free.


proc libusb_transfer_set_stream_id*(transfer: ptr libusb_transfer;
  stream_id: uint32)
  ## Set a transfers bulk stream id.
  ##
  ## Note users are advised to use `libusb_fill_bulk_stream_transfer()` instead
  ## of calling this function directly.
  ##
  ## ``transfer`` - The transfer to set the stream id for.
  ## ``stream_id`` - The stream id to set.


proc libusb_transfer_get_stream_id*(transfer: ptr libusb_transfer): uint32
  ## Get a transfers bulk stream id.
  ##
  ## ``transfer`` - The transfer to get the stream id for.
  ## Returns the stream id for the transfer.


proc libusb_fill_control_transfer*(transfer: ptr libusb_transfer;
  dev_handle: ptr libusb_device_handle; buffer: ptr cuchar;
  callback: libusb_transfer_cb_fn; user_data: pointer; timeout: cuint)
  {.inline.} =
  ## Helper function to populate the required `libusb_transfer` fields for a
  ## control transfer.
  ##
  ## If you pass a transfer buffer to this function, the first 8 bytes will be
  ## interpreted as a control setup packet, and the wLength field will be used to
  ## automatically populate the `length` field of the transfer. Therefore the
  ## recommended approach is:
  ## - Allocate a suitably sized data buffer (including space for control setup)
  ## - Call `libusb_fill_control_setup()`
  ## - If this is a host-to-device transfer with a data stage, put the data
  ##   in place after the setup packet
  ## - Call this function
  ## - Call `libusb_submit_transfer()`
  ##
  ## It is also legal to pass a NULL buffer to this function, in which case this
  ## function will not attempt to populate the length field. Remember that you
  ## must then populate the buffer and length fields later.
  ##
  ## ``transfer`` - The transfer to populate.
  ## ``dev_handle`` - Handle of the device that will handle the transfer.
  ## ``buffer`` - Data buffer. If provided, this function will interpret the first
  ##      8 bytes as a setup packet and infer the transfer length from that. This
  ##      pointer must be aligned to at least 2 bytes boundary.
  ## ``callback`` - Callback function to be invoked on transfer completion.
  ## ``user_data`` - User data to pass to callback function.
  ## ``timeout` - Timeout for the transfer in milliseconds.
  var setup: ptr libusb_control_setup = cast[ptr libusb_control_setup](cast[pointer](buffer))
  transfer.dev_handle = dev_handle
  transfer.endpoint = 0
  transfer.`type` = LIBUSB_TRANSFER_TYPE_CONTROL
  transfer.timeout = timeout
  transfer.buffer = buffer
  if setup:
    transfer.length = (int)(LIBUSB_CONTROL_SETUP_SIZE + libusb_le16_to_cpu(setup.wLength))
  transfer.user_data = user_data
  transfer.callback = callback


proc libusb_fill_bulk_transfer*(transfer: ptr libusb_transfer;
  dev_handle: ptr libusb_device_handle; endpoint: cuchar; buffer: ptr cuchar;
  length: cint; callback: libusb_transfer_cb_fn; user_data: pointer;
  timeout: cuint) {.inline.} =
  ## Helper function to populate the required `libusb_transfer` fields for a
  ## bulk transfer.
  #
  ## ``transfer`` - The transfer to populate.
  ## ``dev_handle`` - Handle of the device that will handle the transfer.
  ## ``endpoint`` - Address of the endpoint where this transfer will be sent.
  ## ``buffer`` - Data buffer.
  ## ``length`` - Length of data buffer.
  ## ``callback`` - Callback function to be invoked on transfer completion.
  ## ``user_data`` - User data to pass to callback function.
  ## ``timeout`` - Timeout for the transfer in milliseconds.
  transfer.endpoint = endpoint
  transfer.`type` = LIBUSB_TRANSFER_TYPE_BULK
  transfer.timeout = timeout
  transfer.buffer = buffer
  transfer.length = length
  transfer.user_data = user_data
  transfer.callback = callback


proc libusb_fill_bulk_stream_transfer*(transfer: ptr libusb_transfer;
  dev_handle: ptr libusb_device_handle; endpoint: cuchar; stream_id: uint32;
  buffer: ptr cuchar; length: cint; callback: libusb_transfer_cb_fn;
  user_data: pointer; timeout: cuint) {.inline.} =
  ## Helper function to populate the required `libusb_transfer` fields for a
  ## bulk transfer using bulk streams.
  ##
  ## ``transfer`` - The transfer to populate.
  ## ``dev_handle`` - Handle of the device that will handle the transfer.
  ## ``endpoint address`` - Of the endpoint where this transfer will be sent.
  ## ``stream_id`` - Bulk stream id for this transfer.
  ## ``buffer`` - Data buffer.
  ## ``length`` - Length of data buffer.
  ## ``callback`` - Callback function to be invoked on transfer completion.
  ## ``user_data`` - User data to pass to callback function.
  ## ``timeout`` - Timeout for the transfer in milliseconds.
  libusb_fill_bulk_transfer(transfer, dev_handle, endpoint, buffer, length, 
                            callback, user_data, timeout)
  transfer.`type` = LIBUSB_TRANSFER_TYPE_BULK_STREAM
  libusb_transfer_set_stream_id(transfer, stream_id)


proc libusb_fill_interrupt_transfer*(transfer: ptr libusb_transfer; 
  dev_handle: ptr libusb_device_handle; endpoint: cuchar; buffer: ptr cuchar;
  length: cint; callback: libusb_transfer_cb_fn; user_data: pointer;
  timeout: cuint) {.inline.} =
  ## Helper function to populate the required `libusb_transfer` fields for an
  ## interrupt transfer.
  ##
  ## ``transfer`` - The transfer to populate.
  ## ``dev_handle`` - Handle of the device that will handle the transfer.
  ## ``endpoint`` - Address of the endpoint where this transfer will be sent.
  ## ``buffer`` - Data buffer.
  ## ``length`` - Length of data buffer.
  ## ``callback`` - Callback function to be invoked on transfer completion.
  ## ``user_data`` - User data to pass to callback function.
  ## ``timeout`` - Timeout for the transfer in milliseconds.
  transfer.dev_handle = dev_handle
  transfer.endpoint = endpoint
  transfer.`type` = LIBUSB_TRANSFER_TYPE_INTERRUPT
  transfer.timeout = timeout
  transfer.buffer = buffer
  transfer.length = length
  transfer.user_data = user_data
  transfer.callback = callback


proc libusb_fill_iso_transfer*(transfer: ptr libusb_transfer;
  dev_handle: ptr libusb_device_handle; endpoint: cuchar; buffer: ptr cuchar;
  length: cint; num_iso_packets: cint; callback: libusb_transfer_cb_fn;
  user_data: pointer; timeout: cuint) {.inline.} =
  ## Helper function to populate the required `libusb_transfer` fields for an
  ## isochronous transfer.
  ##
  ## ``transfer`` - The transfer to populate.
  ## ``dev_handle`` - Handle of the device that will handle the transfer.
  ## ``endpoint`` - Address of the endpoint where this transfer will be sent.
  ## ``buffer`` - Data buffer.
  ## ``length`` - Length of data buffer.
  ## ``num_iso_packets`` - The number of isochronous packets.
  ## ``callback`` - Callback function to be invoked on transfer completion.
  ## ``user_data`` - User data to pass to callback function.
  ## ``timeout`` - Timeout for the transfer in milliseconds.
  transfer.dev_handle = dev_handle
  transfer.endpoint = endpoint
  transfer.`type` = LIBUSB_TRANSFER_TYPE_ISOCHRONOUS
  transfer.timeout = timeout
  transfer.buffer = buffer
  transfer.length = length
  transfer.num_iso_packets = num_iso_packets
  transfer.user_data = user_data
  transfer.callback = callback


proc libusb_set_iso_packet_lengths*(transfer: ptr libusb_transfer;
  length: cuint) {.inline.} =
  ## Convenience function to set the length of all packets in an isochronous
  ## transfer, based on the num_iso_packets field in the transfer structure.
  ##
  ## ``transfer`` - A transfer.
  ## ``length`` - The length to set in each isochronous packet descriptor (see
  ##      `libusb_get_max_packet_size()`.
  var i: cint
  i = 0
  while i < transfer.num_iso_packets:
    transfer.iso_packet_desc[i].length = length
    inc(i)


proc libusb_get_iso_packet_buffer*(transfer: ptr libusb_transfer;
  packet: cuint): ptr cuchar {.inline.} =
  ## Convenience function to locate the position of an isochronous packet within
  ## the buffer of an isochronous transfer.
  ##
  ## This is a thorough function which loops through all preceding packets,
  ## accumulating their lengths to find the position of the specified packet.
  ## Typically you will assign equal lengths to each packet in the transfer,
  ## and hence the above method is sub-optimal. You may wish to use
  ## `libusb_get_iso_packet_buffer_simple()` instead.
  ##
  ## ``transfer`` - A transfer.
  ## ``packet`` - The packet to return the address of.
  ##
  ## Returns the base address of the packet buffer inside the transfer buffer,
  ## or NULL if the packet does not exist
  ## (see `libusb_get_iso_packet_buffer_simple()`).
  var i: cint
  var offset: csize = 0
  var _packet: cint
  # oops..slight bug in the API. packet is an unsigned int, but we use
  #   signed integers almost everywhere else. range-check and convert to
  #   signed to avoid compiler warnings. FIXME for libusb-2. 
  if packet > INT_MAX: return nil
  _packet = cast[cint](packet)
  if _packet >= transfer.num_iso_packets: return nil
  i = 0
  while i < _packet:
    inc(offset, transfer.iso_packet_desc[i].length)
    inc(i)
  return transfer.buffer + offset


proc libusb_get_iso_packet_buffer_simple*(transfer: ptr libusb_transfer;
    packet: cuint): ptr cuchar {.inline.} =
  ## Convenience function to locate the position of an isochronous packet
  ## within the buffer of an isochronous transfer, for transfers where each
  ## packet is of identical size.
  ##
  ## This function relies on the assumption that every packet within the
  ## transfer is of identical size to the first packet. Calculating the location
  ## of the packet buffer is then just a simple calculation:
  ##    <tt>buffer + (packet_size * packet)</tt>
  ##
  ## Do not use this function on transfers other than those that have identical
  ## packet lengths for each packet.
  ##
  ## ``transfer`` - A transfer.
  ## ``packet`` - The packet to return the address of.
  ##
  ## Returns the base address of the packet buffer inside the transfer buffer,
  ## or nil if the packet does not exist (see `libusb_get_iso_packet_buffer()`).
  var _packet: cint
  # oops..slight bug in the API. packet is an unsigned int, but we use
  #   signed integers almost everywhere else. range-check and convert to
  #   signed to avoid compiler warnings. FIXME for libusb-2.
  if packet > INT_MAX:
    return nil
  _packet = cast[cint](packet)
  if _packet >= transfer.num_iso_packets:
    return nil
  return transfer.buffer + (cast[cint](transfer.iso_packet_desc[0].length * _packet))


# Sync I/O #####################################################################

proc libusb_control_transfer*(dev_handle: ptr libusb_device_handle;
  request_type: uint8; bRequest: uint8; wValue: uint16; wIndex: uint16;
  data: ptr cuchar; wLength: uint16; timeout: cuint): cint
  ## Perform a USB control transfer.
  ##
  ## The direction of the transfer is inferred from the bmRequestType field of
  ## the setup packet. The wValue, wIndex and wLength fields values should be
  ## given in host-endian byte order.
  ##
  ## ``dev_handle`` - A handle for the device to communicate with.
  ## ``bmRequestType`` - The request type field for the setup packet.
  ## ``bRequest`` - The request field for the setup packet.
  ## ``wValue`` - The value field for the setup packet.
  ## ``wIndex`` - The index field for the setup packet.
  ## ``data`` - A suitably-sized data buffer for either input or output
  ##    (depending on direction bits within bmRequestType).
  ## ``wLength`` - The length field for the setup packet. The data buffer should
  ##    be at least this size.
  ## ``timeout`` - Timeout (in millseconds) that this function should wait
  ##    before giving up due to no response being received. For an unlimited
  ##    timeout, use value 0.
  ##
  ## Returns
  ##    on success, the number of bytes actually transferred,
  ##    `LIBUSB_ERROR_TIMEOUT` if the transfer timed out,
  ##    `LIBUSB_ERROR_PIPE` if the control request was not supported by the device,
  ##    `LIBUSB_ERROR_NO_DEVICE` if the device has been disconnected,
  ##    another LIBUSB_ERROR code on other failures.


proc libusb_bulk_transfer*(dev_handle: ptr libusb_device_handle;
  endpoint: cuchar; data: ptr cuchar; length: cint; actual_length: ptr cint;
  timeout: cuint): cint
  ## Perform a USB bulk transfer.
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
  ##
  ## ``dev_handle`` - A handle for the device to communicate with.
  ## ``endpoint`` - The address of a valid endpoint to communicate with.
  ## ``data`` - A suitably-sized data buffer for either input or output
  ##            (depending on endpoint).
  ## ``length`` - For bulk writes, the number of bytes from data to be sent.
  ##            For bulk reads, the maximum number of bytes to receive into the
  ##            data buffer.
  ## ``transferred`` - Output location for the number of bytes actually transferred.
  ## ``timeout`` - Timeout (in millseconds) that this function should wait
  ##            before giving up due to no response being received. For an
  ##            unlimited timeout, use value 0.
  ##
  ## Returns
  ##    0 on success (and populates transferred),
  ##    `LIBUSB_ERROR_TIMEOUT` if the transfer timed out (and populates
  ##            transferred),
  ##    `LIBUSB_ERROR_PIPE` if the endpoint halted,
  ##    `LIBUSB_ERROR_OVERFLOW` if the device offered more data, see Packets and
  ##            overflows,
  ##    `LIBUSB_ERROR_NO_DEVICE` if the device has been disconnected another
  ##            `LIBUSB_ERROR` code on other failures.


proc libusb_interrupt_transfer*(dev_handle: ptr libusb_device_handle;
  endpoint: cuchar; data: ptr cuchar; length: cint; actual_length: ptr cint;
  timeout: cuint): cint
  ## Perform a USB interrupt transfer.
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

The default endpoint bInterval value is used as the polling interval.

Parameters
    dev_handle  a handle for the device to communicate with
    endpoint    the address of a valid endpoint to communicate with
    data        a suitably-sized data buffer for either input or output (depending on endpoint)
    length      for bulk writes, the number of bytes from data to be sent. for bulk reads, the maximum number of bytes to receive into the data buffer.
    transferred output location for the number of bytes actually transferred.
    timeout     timeout (in millseconds) that this function should wait before giving up due to no response being received. For an unlimited timeout, use value 0.

Returns
    0 on success (and populates transferred) 
    LIBUSB_ERROR_TIMEOUT if the transfer timed out 
    LIBUSB_ERROR_PIPE if the endpoint halted 
    LIBUSB_ERROR_OVERFLOW if the device offered more data, see Packets and overflows 
    LIBUSB_ERROR_NO_DEVICE if the device has been disconnected 
    another LIBUSB_ERROR code on other error 




proc libusb_get_descriptor*(dev: ptr libusb_device_handle; desc_type: uint8;
  desc_index: uint8_t; data: ptr cuchar;
  length: cint): cint {.inline.} =
  ## Retrieve a descriptor from the default control pipe. This is a convenience
  ## function which formulates the appropriate control message to retrieve the
  ## descriptor.
  ##
  ## ``dev`` - A device handle.
  ## ``desc_type`` - The descriptor type, see `libusb_descriptor_type`.
  ## ``desc_index`` - The index of the descriptor to retrieve.
  ## ``data output`` - Buffer for descriptor.
  ## ``length`` - Size of data buffer.
  ##
  ##  Returns number of bytes returned in data, or LIBUSB_ERROR code on failure.
  return libusb_control_transfer(dev, LIBUSB_ENDPOINT_IN,
    LIBUSB_REQUEST_GET_DESCRIPTOR, (uint16_t)((desc_type shl 8) or desc_index),
    0, data, cast[uint16_t](length), 1000)

#* \ingroup desc
#  Retrieve a descriptor from a device.
#  This is a convenience function which formulates the appropriate control
#  message to retrieve the descriptor. The string returned is Unicode, as
#  detailed in the USB specifications.
# 
#  ``dev`` - A device handle.
#  ``desc_index`` - The index of the descriptor to retrieve.
#  ``langid`` - The language ID for the string descriptor.
#  ``data`` - Output buffer for descriptor.
#  ``length`` - Size of data buffer.
##
#  Returns number of bytes returned in data, or LIBUSB_ERROR code on failure
#  \see libusb_get_string_descriptor_ascii()
# 
proc libusb_get_string_descriptor*(dev: ptr libusb_device_handle; 
                                    desc_index: uint8_t; langid: uint16_t; 
                                    data: ptr cuchar; length: cint): cint {.
    inline.} = 
  return libusb_control_transfer(dev, LIBUSB_ENDPOINT_IN, 
                                  LIBUSB_REQUEST_GET_DESCRIPTOR, (uint16_t)(
      (LIBUSB_DT_STRING shl 8) or desc_index), langid, data, 
                                  cast[uint16_t](length), 1000)

proc libusb_get_string_descriptor_ascii*(dev: ptr libusb_device_handle; 
    desc_index: uint8_t; data: ptr cuchar; length: cint): cint
# polling and timeouts 
proc libusb_try_lock_events*(ctx: ptr libusb_context): cint
proc libusb_lock_events*(ctx: ptr libusb_context)
proc libusb_unlock_events*(ctx: ptr libusb_context)
proc libusb_event_handling_ok*(ctx: ptr libusb_context): cint
proc libusb_event_handler_active*(ctx: ptr libusb_context): cint
proc libusb_lock_event_waiters*(ctx: ptr libusb_context)
proc libusb_unlock_event_waiters*(ctx: ptr libusb_context)
proc libusb_wait_for_event*(ctx: ptr libusb_context; tv: ptr timeval): cint
proc libusb_handle_events_timeout*(ctx: ptr libusb_context; tv: ptr timeval): cint
proc libusb_handle_events_timeout_completed*(ctx: ptr libusb_context; 
    tv: ptr timeval; completed: ptr cint): cint
proc libusb_handle_events*(ctx: ptr libusb_context): cint
proc libusb_handle_events_completed*(ctx: ptr libusb_context; 
                                      completed: ptr cint): cint
proc libusb_handle_events_locked*(ctx: ptr libusb_context; tv: ptr timeval): cint
proc libusb_pollfds_handle_timeouts*(ctx: ptr libusb_context): cint
proc libusb_get_next_timeout*(ctx: ptr libusb_context; tv: ptr timeval): cint


type 
  libusb_pollfd* = object
    ## File descriptor for polling.
    fd*: cint ## Numeric file descriptor 
    events*: cshort ## Event flags to poll for from <poll.h>. POLLIN indicates
    ## that you should monitor this file descriptor for becoming ready to read
    ## from, and POLLOUT indicates that you should monitor this file descriptor
    ## for nonblocking write readiness. 


type 
  libusb_pollfd_added_cb* = proc (fd: cint; events: cshort; user_data: pointer)
  ## Callback function, invoked when a new file descriptor should be added to
  ## the set of file descriptors monitored for events.
  ##
  ## ``fd`` - The new file descriptor.
  ## ``events`` - Events to monitor for, see `libusb_pollfd` for a description.
  ## ``user_data`` - User data pointer specified in the
  ##    libusb_set_pollfd_notifiers() call.


type 
  libusb_pollfd_removed_cb* = proc (fd: cint; user_data: pointer)
  ##  Callback function, invoked when a file descriptor should be removed from
  ##  the set of file descriptors being monitored for events. After returning
  ##  from this callback, do not use that file descriptor again.
  ##
  ##  ``fd`` - The file descriptor to stop monitoring.
  ##  ``user_data`` - User data pointer specified in thei
  ##    `libusb_set_pollfd_notifiers()` call.


proc libusb_get_pollfds*(ctx: ptr libusb_context): ptr ptr libusb_pollfd
  ## Retrieve a list of file descriptors that should be polled by your main loop
  ## as libusb event sources. The returned list is NULL-terminated and should be
  ## freed with free() when done. The actual list contents must not be touched.
  ##
  ## As file descriptors are a Unix-specific concept, this function is not
  ## available on Windows and will always return nil.
  ##
  ## ``ctx`` - The context to operate on, or NULL for the default context.
  ##
  ## Returns
  ##    a NULL-terminated list of libusb_pollfd structures,
  ##    nil on error,
  ##    nil on platforms where the functionality is not available.


proc libusb_set_pollfd_notifiers*(ctx: ptr libusb_context;
  added_cb: libusb_pollfd_added_cb; removed_cb: libusb_pollfd_removed_cb;
  user_data: pointer)
  ## Register notification functions for file descriptor additions/removals.
  ##
  ## These functions will be invoked for every new or removed file descriptor
  ## that libusb uses as an event source. To remove notifiers, pass nil values
  ## for the function pointers.
  ##
  ## Note that file descriptors may have been added even before you register
  ## these notifiers (e.g. at `libusb_init()` time). Additionally, note that the
  ## removal notifier may be called during `libusb_exit()` (e.g. when it is
  ## closing file descriptors that were opened and added to the poll set at
  ## `libusb_init()` time). If you don't want this, remove the notifiers
  ## immediately before calling libusb_exit().
  ##
  ## ``ctx`` - The context to operate on, or NULL for the default context.
  ## ``added_cb`` - Pointer to function for addition notifications.
  ## ``removed_cb`` - Pointer to function for removal notifications.
  ## ``user_data`` - User data to be passed back to callbacks (useful for
  ##    passing context information).


type 
  libusb_hotplug_callback_handle* = cint
  ## Callback handle.
  ##
  ## Callbacks handles are generated by libusb_hotplug_register_callback() and
  ## can be used to deregister callbacks. Callback handles are unique per
  ## `libusb_context` and it is safe to call
  ## `libusb_hotplug_deregister_callback()` on an already deregisted callback.


type
  libusb_hotplug_flag* {.size: sizeof(cint).} = enum ## \
    ## Enumerates flags for hotplug events.
    LIBUSB_HOTPLUG_NO_FLAGS = 0, ## Default value when not using any flags.
    LIBUSB_HOTPLUG_ENUMERATE = 1 shl 0 ## Arm the callback and fire it for all
      ## matching currently attached devices.


type
  libusb_hotplug_event* {.size: sizeof(cint).} = enum ## \
    ## Enumerates hot plug events.
    LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED = 0x00000001, ## A device has been
      ## plugged in and is ready to use.
    LIBUSB_HOTPLUG_EVENT_DEVICE_LEFT = 0x00000002 ## A device has left and is no
      ## longer available. It is the user's responsibility to call `libusb_close`
      ## on any handle associated with a disconnected device. It is safe to call
      ## `libusb_get_device_descriptor` on a device that has left.


const 
  LIBUSB_HOTPLUG_MATCH_ANY* = - 1 ## Wildcard matching for hotplug events.


type 
  libusb_hotplug_callback_fn* = proc (ctx: ptr libusb_context;
    device: ptr libusb_device; event: libusb_hotplug_event; user_data: pointer): cint
  ## Hotplug callback function type. When requesting hotplug event notifications,
  ## you pass a pointer to a callback function of this type.
  ##
  ## This callback may be called by an internal event thread and as such it is
  ## recommended the callback do minimal processing before returning. libusb
  ## will call this function later, when a matching event had happened on a
  ## matching device.
  ##
  ## It is safe to call either libusb_hotplug_register_callback() or
  ## libusb_hotplug_deregister_callback() from within a callback function.
  ##
  ## ``ctx`` - Context of this notification.
  ## ``device`` - The `libusb_device` this event occurred on.
  ## ``event`` - Event that occurred.
  ## ``user_data`` - User data provided when this callback was registered.
  ##
  ## Returns bool whether this callback is finished processing events;
  ## returning 1 will cause this callback to be deregistered.


proc libusb_hotplug_register_callback*(ctx: ptr libusb_context; 
    events: libusb_hotplug_event; flags: libusb_hotplug_flag; vendor_id: cint; 
    product_id: cint; dev_class: cint; cb_fn: libusb_hotplug_callback_fn; 
    user_data: pointer; handle: ptr libusb_hotplug_callback_handle): cint
  ## Register a hotplug callback function.
  ##
  ## Register a callback with the libusb_context. The callback will fire when a
  ## matching event occurs on a matching device. The callback is armed until
  ## either it is deregistered with `libusb_hotplug_deregister_callback()` or
  ## the supplied callback returns 1 to indicate it is finished processing events.
  ##
  ## If the `LIBUSB_HOTPLUG_ENUMERATE` is passed the callback will be called
  ## with `LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED` for all devices already plugged
  ## into the machine. Note that libusb modifies its internal device list from a
  ## separate thread, while calling hotplug callbacks from `libusb_handle_events()`,
  ## so it is possible for a device to already be present on, or removed from,
  ## its internal device list, while the hotplug callbacks still need to be
  ## dispatched. This means that when using `LIBUSB_HOTPLUG_ENUMERATE`, your
  ## callback may be called twice for the arrival of the same device, once from
  ## `libusb_hotplug_register_callback()` and once from `libusb_handle_events()`;
  ## and/or your callback may be called for the removal of a device for which an
  ## arrived call was never made.
  ##
  ## ``ctx`` - Context to register this callback with.
  ## ``events`` - Bitwise or of events that will trigger this callback (see
  ##              `libusb_hotplug_event`)
  ## ``flags`` - Hotplug callback flags (see `libusb_hotplug_flag`).
  ## ``vendor_id`` - The vendor id to match or `LIBUSB_HOTPLUG_MATCH_ANY`.
  ## ``product_id`` - The product id to match or `LIBUSB_HOTPLUG_MATCH_ANY`.
  ## ``dev_class`` - The device class to match or `LIBUSB_HOTPLUG_MATCH_ANY`.
  ## ``cb_fn`` - The function to be invoked on a matching event/device.
  ## ``user_data`` - User data to pass to the callback function.
  ## ``handle`` - Pointer to store the handle of the allocated callback
  ##      (can be nil).
  ##
  ## Returns `LIBUSB_SUCCESS` on success `LIBUSB_ERROR` code on failure.


proc libusb_hotplug_deregister_callback*(ctx: ptr libusb_context;
  handle: libusb_hotplug_callback_handle)
  ## Deregisters a hotplug callback.
  ##
  ## Deregister a callback from a libusb_context. This function is safe to call
  ## from within a hotplug callback.
  ##
  ## ``ctx`` - Context this callback is registered with.
  ## ``handle`` - The handle of the callback to deregister.
