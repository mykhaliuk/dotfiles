# Kill process by port number
function lsofkill
    kill -9 (lsof -ti:$argv[1]) 2>/dev/null; and echo Killed; or echo "Nobody found to kill"
end
