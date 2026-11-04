### Expand .. to cd ../, ... to cd ../../ and .... to cd ../../../ and so on.
function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end

abbr -a dotdot --regex '^\.\.+$' --function multicd
