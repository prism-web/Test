local utils = {}

function utils.read_u32_be(buf, offset)
    local b1 = buffer.readu8(buf, offset)
    local b2 = buffer.readu8(buf, offset+1)
    local b3 = buffer.readu8(buf, offset+2)
    local b4 = buffer.readu8(buf, offset+3)

    return b1 * 256^3 + b2 * 256^2 + b3 * 256 + b4
end

function utils.readAtomType(buf, offset)
    return string.char(
        buffer.readu8(buf, offset),
        buffer.readu8(buf, offset+1),
        buffer.readu8(buf, offset+2),
        buffer.readu8(buf, offset+3)
    )
end

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function utils.decodeBase64(data)
    data = data:gsub('[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do
            r=r .. (f%2^i - f%2^(i-1) > 0 and '1' or '0')
        end
        return r
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        local num: number = tonumber(x,2) :: number
        return string.char(num)
    end))
end

return utils