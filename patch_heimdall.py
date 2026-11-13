# Adapta o Heimdall para usar o descritor USB do termux-usb (Android sem root)
import re, sys
p = sys.argv[1] + "/heimdall/source/BridgeManager.cpp"
s = open(p).read()

def sub(pattern, repl, count=1):
    global s
    new, n = re.subn(pattern, lambda m: repl, s, count=count)
    if n == 0:
        sys.exit("padrao nao encontrado: " + pattern[:60])
    s = new

helper = """
static int TermuxUsbFd(void)
{
    const char *v = getenv("TERMUX_USB_FD");
    return (v && *v) ? atoi(v) : -1;
}

static void TermuxPrepareLibusb(void)
{
#if defined(LIBUSB_API_VERSION) && (LIBUSB_API_VERSION >= 0x01000108)
    if (TermuxUsbFd() >= 0)
        libusb_set_option(NULL, LIBUSB_OPTION_NO_DEVICE_DISCOVERY);
#endif
}

enum
{
    kFileTransferSequenceMaxLengthDefault"""
sub(r"\nenum\s*\{\s*kFileTransferSequenceMaxLengthDefault", helper)
sub(r"int result = libusb_init\(&libusbContext\);",
    "TermuxPrepareLibusb();\n    int result = libusb_init(&libusbContext);", count=0)

sub(r'Interface::Print\("Detecting device\.\.\.\\n"\);\s*struct libusb_device \*\*devices;', r'''Interface::Print("Detecting device...\n");

    int termuxFd = TermuxUsbFd();
    if (termuxFd >= 0)
    {
        int wrapResult = libusb_wrap_sys_device(libusbContext, (intptr_t)termuxFd, &deviceHandle);
        if (wrapResult != LIBUSB_SUCCESS || !deviceHandle)
        {
            Interface::PrintError("Failed to wrap Termux USB fd. libusb error: %d\n", wrapResult);
            return (BridgeManager::kInitialiseFailed);
        }
        heimdallDevice = libusb_get_device(deviceHandle);
        libusb_ref_device(heimdallDevice);
    }
    else
    {
    struct libusb_device **devices;'''.replace(r'\n");', '\\n");'))

sub(r'int result = libusb_open\(heimdallDevice, &deviceHandle\);\s*if \(result != LIBUSB_SUCCESS\)\s*\{\s*Interface::PrintError\("Failed to access device\. libusb error: %d\\n", result\);\s*return \(BridgeManager::kInitialiseFailed\);\s*\}',
    '''int result = libusb_open(heimdallDevice, &deviceHandle);
    if (result != LIBUSB_SUCCESS)
    {
        Interface::PrintError("Failed to access device. libusb error: %d\\n", result);
        return (BridgeManager::kInitialiseFailed);
    }
    }
    int result = LIBUSB_SUCCESS;''')

sub(r'// Get handle to Galaxy S device\s*struct libusb_device \*\*devices;', '''if (TermuxUsbFd() >= 0)
    {
        libusb_device_handle *h = nullptr;
        if (libusb_wrap_sys_device(libusbContext, (intptr_t)TermuxUsbFd(), &h) == LIBUSB_SUCCESS && h)
        {
            libusb_device_descriptor d;
            libusb_get_device_descriptor(libusb_get_device(h), &d);
            libusb_close(h);
            for (int i = 0; i < BridgeManager::kSupportedDeviceCount; i++)
                if (d.idVendor == supportedDevices[i].vendorId && d.idProduct == supportedDevices[i].productId)
                {
                    Interface::Print("Device detected\\n");
                    return (true);
                }
        }
        Interface::PrintDeviceDetectionFailed();
        return (false);
    }

    // Get handle to Galaxy S device
    struct libusb_device **devices;''')

s = "#include <cstdlib>\n#include <cstdint>\n" + s
open(p, "w").write(s)
print("patch aplicado")
