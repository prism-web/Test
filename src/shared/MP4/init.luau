local HttpService = game:GetService("HttpService")
local MP4 = {}

function MP4.getVideo(URL)
	local info = HttpService:PostAsync("http://localhost:3000/base64", HttpService:JSONEncode({
		file = URL
	}))
	require(script.BoxParser).Parse(info)
end

return MP4