# HyperGodot

A Godot plugin and example project for loading assets from the [hypercore-protocol](https://hypercore-protocol.org/).

*WIP:* This is a work an progress and isn't ready for use yet. Feel free to follow for progress, though.

## How It Works:

- Puts all the hypercore-protocol handling into an HTTP [gateway](https://github.com/RangerMauve/hyper-gateway)
- Bundles platform-specific binaries for the gateway
- Subclasses HTTPRequest to auto-spawn gateway and translate `hyper://` requests to `http://127.0.0.1:4973/hyper/`
- Call `request()` as you normally would, but with `hyper://` URLs

## TODOs:

- [x] Reuse `HyperGateway` instance between `HyperRequest` objects
- [x] Example for saving data to hyper
- [ ] Make FTP server that can be mounted as a network drive
- [ ] Listen for changes (EventSource)
- [ ] Listen for download progress (EventSource)
- [ ] Listen for / Publish extension messages (EventSource)
- [ ] Examples for all the methods exposed by the gateway.
- [ ] Basic Multiplayer demo using extension messages
- [ ] Folder sync (From `hyper://` to fs, from fs to `hyper://`)

## Supported APIs:

```JavaScript
// TODO
```
