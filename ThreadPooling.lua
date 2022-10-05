--!strict

-- Last Updated 05/10/22 (English Dates)

--[[
		ThreadPooling V1.0 by rsxpct
		
		Creating threads can be laggy, especially if they are supposed to be there for a split second and/or need to be made frequently.
		This module aims to resolve this lag by pre-creating the threads and holding them in a specific location for you to use later.
		When necessary, the programmer can get one of these threads, use it, then return it to the cache when they are done with it.
			
		HOW TO USE THIS MODULE:
		
			- Coming Soon
--]]

local function assertwarn(Requirement: boolean, MessageIfNotMet: string)
	if Requirement == false then
		warn(MessageIfNotMet)
	end
end

local ThreadPooling = {}
ThreadPooling.__index = ThreadPooling

function ThreadPooling.new(IntegerPrecreatedThreads: number, ShowWarning: boolean)

	assert(IntegerPrecreatedThreads > 0, "PrecreatedThreads can not be negative!")
	assertwarn(IntegerPrecreatedThreads ~= 0, "PrecreatedThreads is 0! This may have adverse effects when using this module.")

	local self = setmetatable({}, ThreadPooling)
	
	
	--// Settings
	self.ShowWarning = ShowWarning or false -- Default = false
	
	--// Thread Tables
	self.Threads = {}
	self.ActiveThreads = {}
	
	--// Initialization
	for _ = 1, IntegerPrecreatedThreads do
		local NewThread = coroutine.create
		table.insert(self.Threads, NewThread)
	end

	return self
end

function ThreadPooling:GetThread(Callback)
	assert(type(Callback) == "function", 'Argument must be a function')

	local Thread = self.Threads[math.random(1, #self.Threads)](Callback)

	coroutine.resume(Thread)

	local PositionInTable

	for Index, Value in ipairs(self.ActiveThreads) do
		if Value == Thread then
			PositionInTable = Index
		end
	end

	table.remove(self.Threads, PositionInTable)
	table.insert(self.ActiveThreads, Thread)
	
	if self.ShowWarning == true then
		warn("[THREAD POOLING] | Used Thread, Call release on this thread when you're done. | [THREAD POOLING]")
	end
	return Thread
end

function ThreadPooling:GetDelayedThread(Yield: number, Callback)
	assert(type(Yield) == "number", "Yield must be a 'number'")
	assert(type(Callback) == "function", "Argument must be a 'function'")

	task.wait(Yield)

	local Thread = self.Threads[math.random(1, #self.Threads)](Callback)

	coroutine.resume(Thread)

	local PositionInTable

	for Index, Value in ipairs(self.ActiveThreads) do
		if Value == Thread then
			PositionInTable = Index
		end
	end

	table.remove(self.Threads, PositionInTable)
	table.insert(self.ActiveThreads, Thread)

	if self.ShowWarning == true then
		warn("[THREAD POOLING] | Used Thread, Call release on this thread when you're done. | [THREAD POOLING]")
	end
	return Thread
end

function ThreadPooling:ReleaseThread(Thread)
	assert(type(Thread) == "thread", "Yield must be a 'thread'")

	local PositionInTable

	for Index, Value in ipairs(self.ActiveThreads) do
		if Value == Thread then
			PositionInTable = Index
		end
	end

	table.remove(self.ActiveThreads, PositionInTable)
	table.insert(self.Threads, Thread)

	coroutine.close(Thread)

	Thread = coroutine.create

	return
end

return ThreadPooling
