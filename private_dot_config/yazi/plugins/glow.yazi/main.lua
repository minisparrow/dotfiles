local M = {}

function M:peek(job)
	local child, err = Command("glow")
		:args({ "--style", "dark", "--width", tostring(job.area.w), tostring(job.file.url) })
		:stdout(Command.PIPED)
		:stderr(Command.NULL)
		:spawn()

	if not child then
		ya.err("Failed to start glow: " .. err)
		return
	end

	local output, _ = child:wait_with_output()
	if not output then
		return
	end

	local lines = {}
	for line in output.stdout:gmatch("([^\n]*)\n?") do
		lines[#lines + 1] = line
	end

	local start = job.skip
	if start >= #lines then
		ya.manager_emit("peek", { math.max(0, #lines - 1), only_if = job.file.url })
		return
	end

	local content = table.concat(lines, "\n", start + 1, math.min(start + job.area.h, #lines))
	ya.preview_widgets(job, { ui.Text.parse(content):area(job.area) })
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		local step = math.floor(job.units * job.area.h / 10)
		ya.manager_emit("peek", {
			math.max(0, cx.active.preview.skip + step),
			only_if = job.file.url,
		})
	end
end

return M
