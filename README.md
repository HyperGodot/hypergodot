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

### How to spawn the daemon

## Supported APIs:

```JavaScript
// TODO
```
