local Connection = {}
Connection.__index = Connection

function Connection.new(callback)
	return setmetatable({
		_Callback = callback
	}, Connection)
end

function Connection:Fire(...)
	self._Callback(...)
end

function Connection:Disconnect()
	self._Callback = nil
	setmetatable(self,nil)
end

return Connection
