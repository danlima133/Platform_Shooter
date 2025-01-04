extends Node

var Signals = Modules.import("utils.signals.data.signals.gd").get_data() as VSignals

func emmit_vsignal(vsignal, args = []):
	if Signals.has_signal(vsignal):
		Signals.emit_signal(vsignal, args)

func connect_vsignal(vsignal, target, callback):
	if Signals.has_signal(vsignal):
		Signals.connect(vsignal, target, callback)

func disconnect_vsginal(vsignal, target, callback):
	if Signals.has_signal(vsignal):
		Signals.disconnect(vsignal, target, callback)
