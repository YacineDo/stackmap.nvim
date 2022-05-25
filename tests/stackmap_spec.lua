local function find_map(mode, lhs)
	local maps = vim.api.nvim_get_keymap(mode)
	for _, map in pairs(maps) do
		if map.lhs == lhs then
			return map
		end
	end
end

describe("stackmap", function()
	local mode = "n"
	local mapping = {
		["asdf"] = "echo 'not existing mapping'",
		["asdfasdf"] = "echo 'existing mapping'",
	}

	before_each(function()
		for lhs, _ in pairs(mapping) do
			pcall(vim.keymap.del, mode, lhs)
		end
		require("stackmap")._stack = {}
	end)

	it("It is working", function()
		require "stackmap"
	end)

	it("push single mapping", function()
		local lhs = "asdf"
		local rhs = "echo 'Yacine'"

		require("stackmap").push("test1", mode, {
			[lhs] = rhs,
		})

		local found = find_map(mode, lhs)
		assert.are.same(rhs, found.rhs)
	end)

	it("push multiple mappings", function()
		require("stackmap").push("test2", mode, mapping)

		for lhs, rhs in pairs(mapping) do
			local found = find_map(mode, lhs)
			assert.are.same(rhs, found.rhs)
		end
	end)

	it("pop single maping", function()
		local lhs = "asdf"
		require("stackmap").push("test3", mode, {
			[lhs] = "echo 'Yacine'",
		})
		require("stackmap").pop "test3"

		local after_pop = find_map(mode, lhs)
		assert.are.same(after_pop, nil)
	end)

	it("pop multiple maping", function()
    local rhs = "echo 'Hello'"
		vim.keymap.set(mode, "asdfasdf", rhs)
		require("stackmap").push("test4", mode, mapping)
		require("stackmap").pop "test4"

		local after_pop = find_map(mode, "asdf")
		assert.are.same(after_pop, nil)

		after_pop = find_map(mode, "asdfasdf")
		assert.are.same(after_pop.rhs, rhs)
	end)
end)
