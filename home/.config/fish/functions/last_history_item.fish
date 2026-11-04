### Expands !! to the last history item
function last_history_item
    echo $history[1]
end

abbr -a !! --position anywhere --function last_history_item
