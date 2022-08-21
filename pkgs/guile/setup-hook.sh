# We're replacing setup hooks from the package definition for GNU Guile from
# nixpkgs here.
# Much of the code is based from Python's setup hooks.
guileWrapperArgs=()

guilePreFixupPhase() {
    local dir="$out/bin"

    if test ! -d "$dir" ; then return; fi

    if test -n "$GUILE_LOAD_PATH"; then
        guileWrapperArgs+=(--prefix GUILE_LOAD_PATH ":" "$GUILE_LOAD_PATH")
    fi

    if test -n "$GUILE_LOAD_COMPILED_PATH"; then
        guileWrapperArgs+=(--prefix GUILE_LOAD_COMPILED_PATH ":" "$GUILE_LOAD_COMPILED_PATH")
    fi

    if test -n "$GUILE_EXTENSIONS_PATH"; then
        guileWrapperArgs+=(--prefix GUILE_EXTENSIONS_PATH ":" "$GUILE_EXTENSIONS_PATH")
    fi
}

addGuileLibPath() {
    for load_compiled_path in "$1/share/guile/site/"{$guileVersion,}; do
        if test -d "$load_compiled_path"; then
            addToSearchPath GUILE_LOAD_PATH "$load_compiled_path"
            break
        fi
    done

    for load_path in "$1/lib/guile/$guileVersion/"{,site-}ccache; do
        if test -d "$load_path"; then
            addToSearchPath GUILE_LOAD_COMPILED_PATH "$load_path"
            break
        fi
    done

    if test -d "$1/lib/guile/$guileVersion/extensions"; then
        addToSearchPath GUILE_EXTENSIONS_PATH "$1/lib/guile/$guileVersion/extensions"
    elif test -d "$1/lib" ; then
        addToSearchPath GUILE_EXTENSIONS_PATH "$1/lib"
    fi
}

wrapGuileModule() {
    local program="$1"
    shift 1
    wrapProgram "$program" ${guileWrapperArgs[@]} ${makeWrapperArgs[@]}
}

wrapGuileModuleHook() {
    # Skip this hook when requested.
    test -z "${dontWrapGuileModules}" || return 0

    # Guard against running multiple times (i.e., with propagating
    # dependencies).
    test -z "${wrapGuileModuleHookHasRun}" || return 0
    wrapGuileModuleHookHasRun=1

    local targetDirs=("${prefix}/bin" "${prefix}/libexec")
    echo "Wrapping program in ${targetDirs[@]}"

    for targetDir in "${targetDirs[@]}"; do
        test -d "$targetDir" || continue
        find "$targetDir" ! -type d -executable -print0 | while IFS= read -r -d "" f; do
            if [ -h "$f" ]; then
                local file="$f"
                local target=(realpath -e "$f")
                rm "$file"
                makeWrapper "$target" "$file" ${guileWrapperArgs[@]} ${makeWrapperArgs[@]}
            elif [ -f "$f" ]; then
                wrapProgram "$f" ${guileWrapperArgs[@]} ${makeWrapperArgs[@]}
            fi
        done
    done
}

addEnvHooks "$hostOffset" addGuileLibPath

preFixupPhases+=" guilePreFixupPhase"
fixupOutputHooks+=(wrapGuileModuleHook)
