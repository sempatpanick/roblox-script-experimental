local function splitStringForParagraphChunks(s, maxChunk)
	if maxChunk < 256 then
		maxChunk = 256
	end
	if s == nil or s == "" then
		return { "" }
	end
	if #s <= maxChunk then
		return { s }
	end
	local chunks = {}
	local pos = 1
	local n = #s
	while pos <= n do
		local endPos = math.min(pos + maxChunk - 1, n)
		if endPos < n then
			local searchStart = math.max(pos, endPos - 500)
			local cut = 0
			for i = endPos, searchStart, -1 do
				if string.byte(s, i) == 10 then
					cut = i
					break
				end
			end
			if cut > pos then
				endPos = cut
			end
		end
		table.insert(chunks, string.sub(s, pos, endPos))
		pos = endPos + 1
	end
	if #chunks == 0 then
		return { s }
	end
	return chunks
end

return {
	splitStringForParagraphChunks = splitStringForParagraphChunks,
}
