extends Node

var _seconds = 0
var _minutes = 0
var _hours = 0

var _percent_minutes = 0
var _percent_hours = 0

var _time = {}

var _stop = false

#@func ref
func _get_seconds(digits):
	return String(_percent_minutes * 60).pad_decimals(digits)

#func ref
func _get_minutes(digits):
	return String(_percent_hours * 60).pad_decimals(digits)

#@func ref
func _get_hours(digits):
	return String(_hours).pad_decimals(digits)

func _update_time(delta):
	_seconds += delta
	if _seconds > 0:
		_minutes = _seconds / 60
	if _minutes > 0:
		_hours = _minutes / 60
	_percent_minutes = _minutes - int(_minutes)
	_percent_hours = _hours - int(_hours)

func _set_time():
	_time["seconds"] = funcref(self, "_get_seconds")
	_time["minutes"] = funcref(self, "_get_minutes")
	_time["hours"] = funcref(self, "_get_hours")

func _ready():
	_set_time()

func _process(delta):
	if not _stop:
		_update_time(delta)

func get_seconds(digits):
	return _time["seconds"].call_funcv([digits])

func get_minutes(digits):
	return _time["minutes"].call_funcv([digits])

func get_hours(digits):
	return _time["hours"].call_funcv([digits])

func stop():
	_stop = true

func resume():
	_stop = false

func restart():
	_seconds = 0
