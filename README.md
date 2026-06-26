# CmdTab

CmdTab is a lightweight, open-source window switcher for macOS. It is a fork of
[AltTab](https://github.com/lwouis/alt-tab-macos), focused on fast keyboard-driven
window switching without Pro features, licensing, window previews, telemetry, or
an automatic-update service.

## Build

CmdTab uses Swift 5.8 and AppKit. It does not require a paid Apple Developer
membership for local development.

```sh
scripts/codesign/setup_local.sh
./ai/build.sh
```

The debug app is written to:

```text
DerivedData/Build/Products/Debug/CmdTab.app
```

The default bundle identifier is `com.hitomeng.cmdtab`. Local builds use a
self-signed certificate, so builds shared with another Mac are not notarized and
may trigger Gatekeeper warnings.

## License

CmdTab remains available under GPL-3.0. See [LICENCE.md](LICENCE.md).

Copyright and attribution for the upstream AltTab project and its contributors
remain preserved in the repository history and contributor documentation.
