# Custom WebSocket endpoint test release

This branch contains the application changes used for the Windows x64 test build, based on RustDesk commit 0bc2473ffe95934408150d48633cd50344c55960. The shared-library change is based on hbb_common commit 229b904508364c8997aad0fb5af57effac859f60 and is tracked as a submodule commit on this repository's hbb-common-websocket branch.

Clone with git clone --recurse-submodules. The original Windows build workflow is preserved on the build/websocket-windows branch. Build the application with the official Windows prerequisites and python build.py --flutter --skip-portable-pack.

Set WebSocket ID Server and WebSocket Relay Server in Settings > Network > ID/Relay Server. Bare host[:port] uses wss and the default /ws/id or /ws/relay path; full ws:// or wss:// URLs preserve the specified path. An explicit trailing / selects the root path.

The released ZIP is the original successful Actions artifact from run 38053558574. Its SHA-256 is 462c63b262c88ea178cbee34c6a50153f8058af1cc823e5f63302eb4975ea8ba. The binary was built before this source publication; only submodule tracking, build-workflow plumbing, and this documentation were added for publication.

Validation: Windows x64 build passed; ZIP integrity, x64 PE files and WebSocket option strings were verified. Model and selected shared-library regression tests passed during patch preparation. Live BetterDesk connectivity remains unverified.

Regression surface: the network-settings dialog, server-config import/export and validation, option persistence/restart notifications, and shared-library WebSocket URL selection. Translation files add the new settings labels. Existing URL selection remains the fallback when no matching custom endpoint is configured.

Known limits: the client uses the official RustDesk service and configuration identity. If the official client is installed, Start service uses the installed executable. Back up the installed application directory and replace the complete application bundle to test the patched service, or use a separate test machine. Older BetterDesk versions may reject mixed WebSocket/native relay sessions; test both peers with WebSocket enabled.
