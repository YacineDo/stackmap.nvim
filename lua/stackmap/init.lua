P = function(t)
	print(vim.inspect(t))
end

local M = {}

local function find_map(mode, lhs)
	local maps = vim.api.nvim_get_keymap(mode)
	for _, value in pairs(maps) do
		if value.lhs == lhs then
			return value
		end
	end
end

M._stack = {}

M.push = function(name, mode, mappings)
	local existing_maps = {}
	for lhs, _ in pairs(mappings) do
		local existing = find_map(mode, lhs)
		if existing then
			existing_maps[lhs] = existing
			-- table.insert(existing_maps, existing)
		end
	end

	M._stack[name] = {
		mode = mode,
		existing = existing_maps,
		mappings = mappings,
	}

	for lhs, rhs in pairs(mappings) do
		-- TODO: need same way to pass options here
		vim.keymap.set(mode, lhs, rhs)
	end
end

M.pop = function(name)
	local stack = M._stack[name]
	M._stack[name] = nil

	for lhs, _ in pairs(stack.mappings) do
		local existing = stack.existing[lhs]
		if existing then
			-- Handel mappings that exist
			vim.keymap.set(stack.mode, lhs, existing.rhs)
		else
			-- Handel mappings that don't exist
			vim.keymap.del(stack.mode, lhs)
		end
	end
end

return M
