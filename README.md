# NonceSet143

Set the APNonce generator and read the APNonce on jailbroken iOS 12 - 14. Released in 2021.

NonceSet143 is no longer maintained. Its successor, **NonceSetX** (Dopamine, iOS 15 - 18 and 26), is available on [ichitaso's Repository](https://cydia.ichitaso.com).

## Requirements
- iOS 12 - 14, jailbroken with kernel read / write for [dimentio](https://github.com/0x7ff/dimentio): tfp0 / hsp4, libkrw or libkernrw

## How it works
The app (`main.m`, `PSAppDelegate.m`) calls `libdimentio.dylib`, built from `dimentio/`, to read and set the generator and to get the APNonce. The app runs as root (setuid).

## Building
1. Build `Resources/libdimentio.dylib`:
   ```sh
   xcrun -sdk iphoneos clang -arch arm64 -arch arm64e -mios-version-min=10.0 dimentio/libdimentio.c \
     -framework IOKit -framework CoreFoundation -lcompression -O2 -dynamiclib \
     -install_name /Applications/NonceSet143.app/libdimentio.dylib -o Resources/libdimentio.dylib
   strip -x Resources/libdimentio.dylib
   ldid -S Resources/libdimentio.dylib
   ```
2. `make package` with [Theos](https://theos.dev).

### Code that is not built
`exploit/` (cicuta_virosa), `postexploit/`, `PatchDebugging/`, `fishhook/`, `patchfinder64.c`, `support.m` and the other kernel helpers are left from an attempt to bundle an exploit. The Makefile does not build them.

## Credits
- [0x7FF/dimentio](https://github.com/0x7ff/dimentio) (Apache License 2.0). `dimentio/` is based on commit `7ffffffde` (2021-03-08) and modified: libkernrw support and build fixes in `libdimentio.c`
- [ModernPwner/cicuta_virosa](https://github.com/ModernPwner/cicuta_virosa) (GPLv3), in `exploit/`
- [facebook/fishhook](https://github.com/facebook/fishhook) (BSD), in `fishhook/`
- xerub (`patchfinder64.c`, from extra_recipe; no license is stated in the file)
- [stek29](https://stek29.rocks/2018/06/26/nvram.html) (nvram unlock, nonce research)

## License
NonceSet143 is licensed under the [GPLv3](LICENSE), since it includes GPLv3 code (`exploit/`). Third-party code keeps its own license.
