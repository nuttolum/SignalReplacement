--[[

                __  __        __              
   ____  __  __/ /_/ /_____  / /_  ______ ___ 
  / __ \/ / / / __/ __/ __ \/ / / / / __ `__ \
 / / / / /_/ / /_/ /_/ /_/ / / /_/ / / / / / /
/_/ /_/\__,_/\__/\__/\____/_/\__,_/_/ /_/ /_/ 
                                              

RBXScriptSignal Replacement

functionally identical!

~EXCEPT~

this can pass metatables too

not SUPER useful but maybe you might find a use for it

to install:

put somewhere you can use it (usually ReplicatedStorage is the best place for this)

use:
	local signalClass = require(game.ReplicatedStorage.signalClass)
	
make a new signal:
	local itHappenedSignal = signalClass.new()
	
wait for the signal to fire:
	itHappenedSignal:Wait()
	print("it happened!")
	
wait returns arguments:

	itHappenedSignal:Fire("hi")
	
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	print(itHappenedSignal:Wait())
	
	(will print "hi")
	
connect and disconnect:
	
	function happen()
		print("it happened")
	end
	
	local con = itHappenedSignal:Connect(happen)

	con:Disonnect()


the main use for this is for things like OOP classes:
	
	function Car.new()
		return setmetatable){
			Stopped = signalClass.new()
		}, Car)
	
	
	end
	
	function Car:Stop()
		self.Stopped:Fire()
	end
	
	~~~~~~~~~~~~~~~~~~~~~~~~~
	
	myCar.Stopped:Connect(function()
		print("my car stopped!")
	end)


]]

local Connection = {}
Connection.__index = Connection

function Connection.new(callback)
	return setmetatable({
		_Callback = callback
	}, Connection)
end

function Connection:Disconnect()
	self._Callback = nil
	setmetatable(self,nil)
end


local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_Threads = {},
		Firing = false
	}, Signal)
end

function Signal:Fire(...)
	for threadOrConnection,_Type in pairs(self._Threads) do
		if _Type == "Connection" then
			if threadOrConnection._Callback == nil then self._Threads[threadOrConnection] = nil else
				task.spawn(threadOrConnection._Callback,...)
			end
		elseif _Type == "ConnectOnce" then
			if threadOrConnection._Callback ~= nil then
				task.spawn(threadOrConnection._Callback,...)
				threadOrConnection:Disconnect()
			end
		elseif _Type == "Wait" then
			self._Threads[threadOrConnection] = nil
			task.spawn(threadOrConnection, ...)
		end
	end
end

function Signal:Wait(duration : number?)
	local Running = coroutine.running()
	self._Threads[Running] = "Wait"
	if duration then
		task.delay(duration, function(thread)
			local stillYielding = self._Threads[thread]
			if stillYielding then
				self._Threads[thread] = nil
				task.spawn(thread)
			end
		end, Running)
	end
	return coroutine.yield()
end

function Signal:Connect(callback: () -> ())
	local connection = Connection.new(callback)
	self._Threads[connection] = "Connection"
	return connection
end

function Signal:ConnectOnce(callback: () -> ())
	local connection = Connection.new(callback)
	self._Threads[connection] = "ConnectOnce"
	return connection
end

function Signal:Destroy()

	self._Connections = nil
	self._Yielding = nil
	self.Firing = nil
	setmetatable(self,{__index = function() return nil end})

end


return Signal


