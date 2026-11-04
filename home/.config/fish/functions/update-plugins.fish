function update-plugins --description 'Update all Claude Code marketplaces and installed plugins'
    claude plugin marketplace update; or return

    set -l failed
    for entry in (claude plugin list --json | jq -r '.[] | select(.scope | IN("user", "project", "local", "managed")) | "\(.id) \(.scope)"')
        set -l parts (string split ' ' $entry)
        echo "→ $parts[1] ($parts[2])"
        claude plugin update $parts[1] -s $parts[2] -y; or set -a failed $parts[1]
    end

    if set -q failed[1]
        echo "Failed: $failed" >&2
        return 1
    end
    echo 'Done. Restart Claude Code to apply.'
end
