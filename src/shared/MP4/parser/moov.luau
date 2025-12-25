local utils = require(script.Parent.utils)
return function(boxes, videoBuffer)
    local traks = {}

    local offset = boxes.moov.offset + 8
    while offset < boxes.moov.offset + boxes.moov.size do
        local size = utils.read_u32_be(videoBuffer, offset)
        local type = utils.readAtomType(videoBuffer, offset+4)
        if type == "trak" then
            local tkhd = {}
            tkhd.offset = offset + 8
            tkhd.size = utils.read_u32_be(videoBuffer, tkhd.offset)
            tkhd.type = utils.readAtomType(videoBuffer, tkhd.offset+4)
            tkhd.version = buffer.readu8(videoBuffer, tkhd.offset+8)
            if tonumber(tkhd.version) == 0 then
                tkhd.creation = utils.read_u32_be(videoBuffer, tkhd.offset+12)
                tkhd.modification = utils.read_u32_be(videoBuffer, tkhd.offset+16)
                tkhd.trackId = utils.read_u32_be(videoBuffer, tkhd.offset+20)
                tkhd.reserved = utils.read_u32_be(videoBuffer, tkhd.offset+24)
                tkhd.duration = utils.read_u32_be(videoBuffer, tkhd.offset+28)
                tkhd.width = utils.read_u32_be(videoBuffer, tkhd.offset + tkhd.size - 8) / 65536
                tkhd.height = utils.read_u32_be(videoBuffer, tkhd.offset + tkhd.size - 4) / 65536
            end
            
            local mdia = {}
            mdia.offset = tkhd.offset + tkhd.size
            
            mdia.size = utils.read_u32_be(videoBuffer, mdia.offset)
            mdia.type = utils.readAtomType(videoBuffer, mdia.offset+4)

            print(utils.readAtomType(videoBuffer, mdia.offset+4))

            table.insert(traks, {
                offset = offset,
                size = size,
                type = tkhd.type
            })
        end
        offset += size
    end
end
