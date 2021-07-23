extends HTTPEventSource

class_name HyperEventSource

signal loading_data(url)

export var serverPrefix = "http://127.0.0.1:4973/hyper/"

var watching = false

func request(
	url,
	custom_headers=PoolStringArray( ),
	ssl_validate_domain=false,
	method=HTTPClient.METHOD_GET, request_data=""
):
	assert(url.begins_with("hyper://"))
	var toLoad = url.replace("hyper://", serverPrefix)
	emit_signal('loading_data', url)
	.request(toLoad, custom_headers, ssl_validate_domain, method, request_data)
pass
