/*
                                @@@@@@&
                            @@@@@@@@@@@@@@@
                       %@@@@@@@@@@@@@@@@@@@@@@@
                   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&
               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        @@  %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ,@/
     @@@@@  @@@@@@@@@@@@@@@@@@@@@     @@@@@@@@@@@@@@@@@@@@&  @@@@@
  &@@@@@@   @@@@@@@@@@@@@@@@&             @@@@@@@@@@@@@@@@&   @@@@@@
 @@@@@      @@@@@@@@@@@@@&                   @@@@@@@@@@@@@&     ,@@@@@
@@@@%       @@@@@@@@@@@@@&                   @@@@@@@@@@@@@&       @@@@@
@@@@        @@@@@@@@@@@@@&                   @@@@@@@@@@@@@&       ,@@@@
@@@@@       @@@@@@@@@@@@@&                   @@@@@@@@@@@@@&       @@@@@
 @@@@@      @@@@@@@@@@@@@&                   @@@@@@@@@@@@@&     (@@@@@
  /@@@@@@    @@@@@@@@@@@@@@@@             @@@@@@@@@@@@          @@@@
     @@@@@@@@      *@@@@@@@@@@@@@    (@@@@@@@@@@@@@    @@@@@@@@  @
        (@@@@@@@@@@@*                             &@@  @@@@@@@@
             *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   @@@@
                      @@@@@@@@@@@@@@@@@@@@@@@@@@%

                            @@@@@@@@@@@@@@@
                                &@@@@@
*/

galactic = {}
galactic.registeredComponents = {}
galactic.components = {}
galactic.initialized = false
galactic.registry = debug.getregistry()
local border = "="
local prefix = "GA > "

local function PrintBig(msg)
	local line = ""

	msg = border .. " " .. msg .. " " .. border

	for i=1,string.len(msg) do
		line = line .. border
	end

	print(line)
	print(msg)
	print(line)
end

local function PrintSmall(msg)
	local col = Color( 137, 222, 255 )
	if CLIENT then
		col = Color( 255, 222, 102 )
	end
	MsgC(col, prefix .. msg .. "\n" )
end
local function PrintSmallWarn(msg) MsgC( Color( 255, 255, 55 ), prefix .. msg .. "\n" ) end
local function PrintSmallGood(msg) MsgC( Color( 55, 255, 55 ), prefix .. msg .. "\n" ) end
local function PrintSmallErro(msg) MsgC( Color( 255, 55, 55 ), prefix .. msg .. "\n" ) end


local function PrintSmallNoLine(msg)
	local col = Color( 137, 222, 255 )
	if CLIENT then
		col = Color( 255, 222, 102 )
	end
	MsgC(col, msg )
end
local function PrintSmallWarnNoLine(msg) MsgC( Color( 255, 255, 55 ), msg ) end
local function PrintSmallGoodNoLine(msg) MsgC( Color( 55, 255, 55 ), msg ) end
local function PrintSmallErroNoLine(msg) MsgC( Color( 255, 55, 55 ), msg ) end

function galactic:ComponentTitle(component)	return (component.title or tostring(component)) end

/**
 * Component
**/

function galactic:Register(component)
	for i = #self.registeredComponents, 1, -1 do
		local v = self.registeredComponents[i]
		if self:ComponentTitle(v) == self:ComponentTitle(component) then
			table.remove(self.registeredComponents, i)
		end
	end

	if self.initialized then
		table.insert(self.registeredComponents, 1, component)
		local fcn = {}
		self:LoadComponents(fcn)
	else
		table.insert(self.registeredComponents, component)
	end
end

function galactic:LoadComponents(failedComponentNamespaces)
	local shouldContinue = true
	local skips = 0
	failedComponentNamespaces = failedComponentNamespaces or {}
	while shouldContinue do
		if #self.registeredComponents > skips then
			local componentToBeLoaded = self.registeredComponents[skips + 1]

			local alreadyAttemptedFailedComponent = false
			if componentToBeLoaded.namespace then
				for i, failedComponentNamespace in ipairs(failedComponentNamespaces) do
					if failedComponentNamespace == componentToBeLoaded.namespace then
						alreadyAttemptedFailedComponent = true
						break
					end
				end
			end

			local componentLoaded = false
			if not alreadyAttemptedFailedComponent then
				componentLoaded = self:LoadComponent(componentToBeLoaded, failedComponentNamespaces)
			end

			if not componentLoaded then
				skips = skips + 1
			end
		else
			shouldContinue = false
		end
	end
end

function galactic:LoadComponent(component, failedComponentNamespaces)

	if component.dependencies then // Component requires dependencies

		local missingDependencies = {}

		for _, componentDependencyNamespace in pairs(component.dependencies) do
			if not self[componentDependencyNamespace] then // Dependency currently doesn't exists

				local dependencyLoaded = false

				local alreadyFailed = false
				for i, failedComponentNamespace in ipairs(failedComponentNamespaces) do
					if failedComponentNamespace == componentDependencyNamespace then
						alreadyFailed = true
					end
				end

				if not alreadyFailed then
					for key = #self.registeredComponents, 1, -1 do // Find dependency and load it
						local dependency = self.registeredComponents[key]
						if dependency.namespace == componentDependencyNamespace then
							dependencyLoaded = self:LoadComponent(dependency, failedComponentNamespaces)
							break
						end
					end
				end

				if not dependencyLoaded then
					table.insert(missingDependencies, componentDependencyNamespace)
				end
			end
		end

		if #missingDependencies > 0 then
			PrintSmallNoLine(prefix .. "Loading " .. self:ComponentTitle(component) .. ".. ")
			PrintSmallWarnNoLine("MISSING: ")

			for i, v in ipairs(missingDependencies) do
				if i == 1 then
					PrintSmallWarnNoLine(v)
				else
					PrintSmallWarnNoLine(", " .. v)
				end
			end

			PrintSmallWarnNoLine("\n")

			if component.namespace then
				table.insert(failedComponentNamespaces, component.namespace)
			end
			return false
		end
	end

	// All dependencies loaded
	local oldNamespace
	if component.namespace then
		oldNamespace = self[component.namespace]
		self[component.namespace] = component
	end

	local success = ProtectedCall(function() self:ExecuteComponentInitialize(component) end)

	PrintSmallNoLine(prefix .. "Loading " .. self:ComponentTitle(component) .. ".. ")

	if success then

		local foundOld = false
		for i, v in ipairs(self.components) do
			if self:ComponentTitle(v) == self:ComponentTitle(component) then
				PrintSmallNoLine("FOUND\n" .. prefix .. "Replacing " .. self:ComponentTitle(component) .. ".. ")
				self.components[i] = component
				foundOld = true
			end
		end

		if not foundOld then
			table.insert(self.components, component)
		end
		table.RemoveByValue(self.registeredComponents, component)

		PrintSmallGoodNoLine("SUCCESS\n")

		return true
	else
		PrintSmallErroNoLine("ERROR\n")

		// Recall namespace placement
		if component.namespace then
			self[component.namespace] = oldNamespace
		end

		if component.namespace then
			table.insert(failedComponentNamespaces, component.namespace)
		end
		return false
	end

end

function galactic:ExecuteComponentInitialize(component)
	if component.Constructor then
		component:Constructor()
	end

	hook.Run("ComponentInitialized", component)

end

function galactic:Initialize()

	if not galactic.HookCall then
		galactic.HookCall = hook.Call
	end

	function hook.Call(name, gm, ...)
		local a, b, c, d, e, f

		for _, component in ipairs(galactic.components) do
			if component[name] then
				a, b, c, d, e, f = component[name](component, ...)

				if a != nil then
					return a, b, c, d, e, f
				end
			end
		end
		
		return galactic.HookCall(name, gm, ...)
	end

	self:LoadComponents()
	self.initialized = true
	PrintBig("Galactic Core loaded")
end
