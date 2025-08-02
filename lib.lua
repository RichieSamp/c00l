
return {
	CreateWindow = function(title, size, toggleKey)
		local Tabs = {}
		local Library = {}

		function Library:CreateTab(name)
			local Tab = {}
			Tab.name = name

			function Tab:CreateToggle(label, callback)
				print("Toggle:", label)
			end

			function Tab:CreateSlider(label, min, max, callback, default)
				print("Slider:", label, "Default:", default)
			end

			table.insert(Tabs, Tab)
			return Tab
		end

		return Library
	end
}
