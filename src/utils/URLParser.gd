var urlParseRegex = RegEx.new()

const DEFAULT_PORTS = {
	"http": 80,
	"https": 443
}

func _init():
	urlParseRegex.compile("([^:]+)://([^/]+)(/?.*)")

func parse(url):
	var parsed = urlParseRegex.search(url)
	
	if !parsed: return null

	var protocol = parsed.get_string(1).to_lower()
	var raw_host = parsed.get_string(2)
	var path = parsed.get_string(3)
	var host = raw_host
	var port = DEFAULT_PORTS[protocol] if DEFAULT_PORTS.has(protocol) else 0
	var ssl = protocol == "https"

	if ":" in raw_host:
		var split = raw_host.split(':')
		host = split[0]
		port = split[1].to_int()

	return {
		"protocol": protocol,
		"host": host,
		"port": port,
		"path": path,
		"ssl": ssl,
	}
