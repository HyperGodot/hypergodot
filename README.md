# HyperGodot

A Godot plugin and example project for loading assets from the [hypercore-protocol](https://hypercore-protocol.org/).

*WIP:* This is a work an progress and may have breaking changes. Feel free to follow for progress, though.

## How It Works:

- Puts all the hypercore-protocol handling into an HTTP [gateway](https://github.com/RangerMauve/hyper-gateway)
- Bundles platform-specific binaries for the gateway
- Subclasses HTTPRequest to auto-spawn gateway and translate `hyper://` requests to `http://127.0.0.1:4973/hyper/`
- Call `request()` as you normally would, but with `hyper://` URLs

## TODOs:

- [x] Reuse `HyperGateway` instance between `HyperRequest` objects
- [x] Example for saving data to hyper
- [x] Make FTP server that can be mounted as a network drive
- [x] Listen for changes (EventSource)
- [x] Listen for download progress (EventSource)
- [x] Listen for / Publish extension messages (EventSource)
- [ ] Examples for all the methods exposed by the gateway.
	- [x] GET/PUT text files
	- [x] Watch for changes
	- [x] Basic chat app
- [x] Load latest hyper-gateway dynamically on boot
- [ ] Basic Multiplayer demo using extension messages
	- [x] Refactor chat system to be more general purpose (not just texts)
	- [x] Basic demo moving blobs around on a map
	- [x] Place usernames in a hyperdrive's json file along with an image for your blob
	- [ ] Create custom maps from an image and a JSON file
	- [ ] Auto-discover which maps are active
- [ ] Enable code to work in Godot Web in Agregore
	- [ ] Use new [JavaScriptObject](https://godotengine.org/article/godot-web-progress-report-9) API from Godot 4
- [ ] Enable code to work in Godot Web in regular browsers
- [ ] Load gltf scene from hyper
- [ ] Load VRM avatar from hyper (social multiplayer) [VRM stuff](https://github.com/V-Sekai/godot-vrm/blob/godot3/addons/vrm/import_vrm.gd)
- [ ] Folder sync (From `hyper://` to fs, from fs to `hyper://`)

## Supported APIs:

```JavaScript
// TODO
```
