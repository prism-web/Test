local BoxParser = {}

local function read_u32_be(buf, offset)
    local b1 = buffer.readu8(buf, offset)
    local b2 = buffer.readu8(buf, offset+1)
    local b3 = buffer.readu8(buf, offset+2)
    local b4 = buffer.readu8(buf, offset+3)

    return b1 * 256^3 + b2 * 256^2 + b3 * 256 + b4
end

local function ReadType(buf, offset)
    return string.char(
        buffer.readu8(buf, offset),
        buffer.readu8(buf, offset+1),
        buffer.readu8(buf, offset+2),
        buffer.readu8(buf, offset+3)
    )
end

local function SplitText()
    print("----------------------")
end

function BoxParser.Parse(data)
    local decodedData = require(script.B64Decoder)(data)
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
    while offset < buffer.len(videoBuffer) do
        local size = read_u32_be(videoBuffer, offset)
        local type = ReadType(videoBuffer, offset+4)
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

    -- Anything beyond this point is unoptimized and will be fixed later.
    
    local traks = {}

    offset = boxes.moov.offset + 8
    while offset < boxes.moov.offset + boxes.moov.size do
        local size = read_u32_be(videoBuffer, offset)
        local type = ReadType(videoBuffer, offset+4)
        if type == "trak" then
            local tkhd = {}
            tkhd.offset = offset + 8
            tkhd.size = read_u32_be(videoBuffer, tkhd.offset)
            tkhd.type = ReadType(videoBuffer, tkhd.offset+4)
            tkhd.version = buffer.readu8(videoBuffer, tkhd.offset+8)
            print(tkhd.version)
            if tonumber(tkhd.version) == 0 then
                tkhd.creation = read_u32_be(videoBuffer, tkhd.offset+12)
                tkhd.modification = read_u32_be(videoBuffer, tkhd.offset+16)
                tkhd.trackId = read_u32_be(videoBuffer, tkhd.offset+20)
                tkhd.reserved = read_u32_be(videoBuffer, tkhd.offset+24)
                tkhd.duration = read_u32_be(videoBuffer, tkhd.offset+28)
                tkhd.width = read_u32_be(videoBuffer, tkhd.offset + tkhd.size - 8) / 65536
                tkhd.height = read_u32_be(videoBuffer, tkhd.offset + tkhd.size - 4) / 65536
            end

            local mdia = {}
            mdia.offset = tkhd.offset + tkhd.size
            
            mdia.size = read_u32_be(videoBuffer, mdia.offset)
            mdia.type = ReadType(videoBuffer, mdia.offset+4)

            print(ReadType(videoBuffer, mdia.offset+4))

            table.insert(traks, {
                offset = offset,
                size = size,
                type = tkhd.type
            })
        end
        offset += size
    end

    return videoBuffer
end

return BoxParser