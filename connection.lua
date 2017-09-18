local M, module = {}, ...

function validate(c)
    return c == "green" or c == "yellow" or c == "red"
end

function sendFile(filename, client)
    local f = file.open(filename,"r")
    client:send(file.read())
    file.close()
    return
end

function M.handle(client, request)
    package.loaded[module]=nil

    local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
    if(method == nil)then
        _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
    end
    local _GET = {}
    if (vars ~= nil)then
        for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
            _GET[k] = v
        end
    end

    local color = string.match(request,"/(%?c=%w+)")
    if (color ~= nil) then
      color = string.match(color,"(=%w+)")
      color = string.match(color,"(%w+)")
    end

    if color then
        color = string.lower(color)
    else
        color = ""
    end

    if method == "GET" and path == "/" then
        sendFile("index.html", client)
        return 200, method, color
    elseif method == "GET" and path == "/styles.css" then
        sendFile("styles.css", client)
        return 200, method, color
    else
        local buf = "HTTP/1.1 400 Bad Request\n\n"
        buf = buf .. "cannot process request: " .. method .. " " .. path .. "\n"

        client:send(buf)
        return 400, method, color
    end
end

return M
