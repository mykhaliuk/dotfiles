function wt-deps --description 'Link node_modules to the main checkout when deps match, else install'
    set -l wt (git rev-parse --show-toplevel); or return 1
    set -l main (dirname (git rev-parse --path-format=absolute --git-common-dir))
    if test "$wt" = "$main"
        echo 'wt-deps: already in the main checkout' >&2
        return 1
    end
    set -q GITHUB_TOKEN; or set -lx GITHUB_TOKEN (gh auth token)

    for src in $main/node_modules $main/*/node_modules
        test -d $src; and not test -L $src; or continue
        set -l pkg (string replace -r '^/?(.*?)/?node_modules$' '$1' -- (string replace -- $main '' $src))
        test -n "$pkg"; or set pkg .
        set -l from $main/$pkg
        set -l dst $wt/$pkg
        test -f $dst/package.json; or continue

        set -l same 1
        for file in package.json yarn.lock
            if test -e $from/$file -o -e $dst/$file
                cmp -s $from/$file $dst/$file; or set same 0
            end
        end

        if test $same = 1
            if not test -L $dst/node_modules
                rm -rf $dst/node_modules
                ln -s $from/node_modules $dst/node_modules
            end
            echo "linked  $pkg"
        else
            test -L $dst/node_modules; and rm $dst/node_modules
            echo "install $pkg"
            yarn --cwd $dst install --frozen-lockfile --prefer-offline; or return 1
        end
    end

    set -l hooks (git config core.hooksPath)
    if test -n "$hooks"; and not string match -q '/*' -- $hooks; and test -d $main/$hooks
        mkdir -p $wt/$hooks
        cp -Rn $main/$hooks/. $wt/$hooks/
        echo "hooks   $hooks"
    end
end
