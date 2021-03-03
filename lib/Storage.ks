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
	
	function SetValue{
		parameter key, val.
		set storage[key] to val.
	}
	
	function SaveStorage{
		WRITEJSON(storage, filePath).
	}
	function DeleteStorage{
		if EXISTS(filePath) 
			DELETEPATH(filePath).
	}
	
	return lexicon(
		"GetValue",GetValue@,
		"SetValue",SetValue@,
		"Save",SaveStorage@,
		"Delete",DeleteStorage@
	).
}
function ShipTypeStorage{
	return GeneralStorage("0:/Specific/Storage/"+ship:NAME).
}
function LocalStorage{
	return GeneralStorage("1:/PersistentStorage").
}