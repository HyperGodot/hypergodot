# HyperGodot

A Godot plugin and example project for loading assets from the [hypercore-protocol](https://hypercore-protocol.org/).

*WIP:* This is a work an progress and isn't ready for use yet. Feel free to follow for progress, though.

## Plans:

- Create a node-js based gateway using the `hypercore-fetch` module listening on http://localhost/
- Use HTTPClient in GDScript to connect to the gateway
- Spawn gateway from within Godot in a singleton
- Intercept the resource loading code to support `hyper://`?

## Research:

### How to spawn the daemon

- [Use pkg](https://www.npmjs.com/package/pkg) to compile [hyper-gateway](https://github.com/RangerMauve/hyper-gateway)
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
