extends Area3D
class_name ProxObject

#
# This object MUST be a direct child to the object 
# you wish to disable by proximity
#

func disable_parent():
	print("disabling ", get_parent())

func enable_parent():
	print("enabling ", get_parent())
