--!strict
local moov = require(script.moov)
local utils = require(script.utils)
local BoxParser = {}

local function SplitText()
    print("----------------------")
end

function BoxParser.Parse(data)
    local decodedData = utils.decodeBase64(data)
    local videoBuffer = buffer.fromstring(decodedData)

    print("Stage 1: Parsing (2)")
    print(`Created buffer - {videoBuffer}`)

    SplitText()

    -- [[ Finding all topmost boxes/atoms needed ]]
    local needed = {
        "ftyp",
        "moov",
        "mdat"
    }

    print(`Searching for boxes - {table.concat(needed, ", ")}`)

    local boxes = {}
    local offset = 0
    while offset < buffer.len(videoBuffer) and #needed > 0 do
        local size = utils.read_u32_be(videoBuffer, offset)
        local type = utils.readAtomType(videoBuffer, offset+4)
        boxes[type] = {
            offset = offset,
            size = size
        }
        local found = table.find(needed, type)
        if found then
            table.remove(needed, found)
            print(`{type} found. Remaining: {#needed > 0 and table.concat(needed, ", ") or "none"}`)
        end
        offset += size
    end

    print(`{#needed} Boxes missing.`)
    if (#needed <= 0) then
        print("Passed")
    else
        print("Failed to fetch all boxes.")
        return
    end

    SplitText()

    moov(boxes, videoBuffer)

    -- Anything beyond this point is unoptimized and will be fixed later.
    
    

    return videoBuffer
end

return BoxParser