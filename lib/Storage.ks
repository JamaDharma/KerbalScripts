RUNONCEPATH("0:/lib/Debug").
function GeneralStorage{
	parameter filePath.
	
	local storage is LoadStorage().
	
	function LoadStorage{
		if EXISTS(filePath)
			return READJSON(filePath).
		else 
			return lexicon().
	}
	
	function GetValue{
		parameter key.
		return storage[key].
	}
	function GetValueSafe{
		parameter key, result.
		if storage:HASKEY(key)
			set result to storage[key].
		return result.
	}
	function SetValue{
		parameter key, val.
		set storage[key] to val.
	}
	function RemoveValue{
		parameter key.
		if storage:HASKEY(key)
			storage:REMOVE(key).
	}
	
	function SaveStorage{
		WRITEJSON(storage, filePath).
	}

	
	return lexicon(
		"GetValue",GetValue@,
		"GetValueSafe",GetValueSafe@,
		"SetValue",SetValue@,
		"RemoveValue",DeleteValue@,
		"Save",SaveStorage@
	).
}
function ShipTypeStorage{
	return GeneralStorage("0:/Specific/Storage/"+ship:NAME).
}
function LocalStorage{
	return GeneralStorage("1:/PersistentStorage").
}