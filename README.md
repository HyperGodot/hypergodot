# HyperGodot

A Godot plugin and example project for loading assets from the [hypercore-protocol](https://hypercore-protocol.org/).

*WIP:* This is a work an progress and isn't ready for use yet. Feel free to follow for progress, though.

## Plans:

- Create a node-js based daemon using the `hypercore-fetch` module listening on UNIX domain sockets / Windows named pipes listening on HTTPs
- Use HTTPClient in GDScript to connect over the unix socket
- Intercept the resource loading code to support `hyper://`?
- Spawn daemon from within Godot in a singleton

## Research:

### How to communicate over UNIX sockets

- StreamPeer seems to [imply UNIX sockets are supported](https://docs.godotengine.org/en/stable/classes/class_streampeer.html#description)
- Looks like it isn't actually supported: https://github.com/godotengine/godot/issues/48862
- Also no support for windows sockets
- Could implement, or go with something else.

### How to spawn the daemon

- Bundle daemon binaries with the project
- Use [OS.execute](https://docs.godotengine.org/en/stable/classes/class_os.html#class-os-method-execute) with non-blocking mode enabled.
- Ensure the process is killed before exiting?

### How to interface with resource loader

- Would need to recompile godot to support protocols other than `res://`
- Right now it renames `res://` to the resource_path
- Then treats it like a regular file to load
- Would need to instead add a set of protocols to load resources from (including hyper)

## Supported APIs:

```JavaScript
// TODO
```
