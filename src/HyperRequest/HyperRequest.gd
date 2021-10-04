extends HTTPRequest

class_name HyperRequest

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

	return .request(toLoad, custom_headers, ssl_validate_domain, method, request_data)

# Only available in 3.3
#func request_raw(
#	url: String,
#	custom_headers : PoolStringArray=PoolStringArray(),
#	ssl_validate_domain: bool =true,
#	method=0,
#	request_data_raw: PoolByteArray=PoolByteArray( )
#):
#	assert(url.begins_with("hyper://"))
#	var toLoad = url.replace("hyper://", serverPrefix)
#
#	return .request_raw(toLoad, custom_headers, ssl_validate_domain, method, request_data_raw)
