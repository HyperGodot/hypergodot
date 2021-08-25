# Least Recently Used Cache
## Use this if you want to keep track of a set, but with a limit

# Map from value to time last used
var values = {}
const DEFAULT_SIZE = 512

var max_size = DEFAULT_SIZE

func _init(new_max = DEFAULT_SIZE):
	max_size = new_max

func has(value):
	return value in values
	pass

func track(value):
	var time = OS.get_system_time_msecs()
	
	values[value] = time
	pass

func is_full():
	return size() > max_size

func size():
	return values.size()

func clear_oldest():
	var oldest = get_oldest()
	values.erase(oldest)
	pass
	
func get_oldest():
	var oldestTime = OS.get_system_time_msecs()
	var oldestValue = null
	for value in values.keys():
		var valueTime = values[value]
		if valueTime < oldestTime:
			oldestTime = valueTime
			oldestValue = value
	return oldestValue
