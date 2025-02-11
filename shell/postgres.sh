#!/usr/bin/env bash

# ------------------------------------------------------------------
#      Script contains a collection of functions that
#
#      1. set postgres ENV vars ( changing default behaviour )
#      2. client tools ( modify the PATH )
#
#          client tools supported ( macports, dbngin, laravel herd )
#
#       TLDR call switch_postgres
# ------------------------------------------------------------------


# ---------- Postgresql 9.5 compatability  -------------------------
#
#      1. Clients tools prior to v12 should be ok to use (at a stretch)
#      2. Postgres extension dependency - hashlib extension
#
# ----------- 👍 Compatible ----------------------------------------
#
#      1. macports - fully supports 9.5 and pghashlib
#      2. orbstack - fully supports 9.5 and pghashlib
#
# ----------- ✋ Incompatible ( can't run postgres 9.5 ) -----------
#
#      brew, DBNGIN, Laravel Herd, EDB Postgres, Postgres.app
#          don't support 9.5 or their 9.5.xx versions are incompatible.
#
# ----------- 👍 client tools + partial compatability --------------
#
#      1. DBNGIN - v10-16 ( <14 intel only )
#      2. Laravel Herd - v14-16
#
# ------------------------------------------------------------------

if test -t 1; then
    # Determine if colors are supported...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test "$ncolors" -ge 8; then
        BOLD="$(tput bold)"
        YELLOW="$(tput setaf 3)"
        GREEN="$(tput setaf 2)"
        RED="$(tput setaf 1)"
        NC="$(tput sgr0)"
    fi
fi

function switch_postgres() {
    if [ $# -ne 0 ]; then
        echo "no support for args in switch_postgres"
        return 0
    fi
    switch_postgres_cli_client "$@"
    echo
    switch_postgres_env_vars "$@"
    pgenv_store
}


function switch_postgres_cli_client() {
    if [ $# -ne 0 ]; then
        echo "no support for args in switch_postgres"
        return 0
    fi
    local pgversion
    local pgname
    local pgVerArr
    echo ""
    echo -e "🐘 Postgresql client\n--------------------"
    # PS3="Select client: "
    pgVerArr=()
    for pgversion in $(macports_postgresql_versions); do
        pgVerArr+=("MacPorts-$pgversion")
    done
    # for pgversion in $(herd_postgresql_versions); do # All Herd versions installed
    for pgversion in $(herd_postgresql_versions_running); do
        pgVerArr+=("Herd-$pgversion")
    done
    for pgversion in $(dbngin_versions); do
        pgVerArr+=("DBngin-$pgversion")
    done
    COLUMNS=1; select pgname in "${pgVerArr[@]}"; do
        pgversion="$(echo "$pgname"|cut -d'-' -f2)"
        if [ -z "$pgversion" ]; then
            echo "version unknown"
            return 1
        fi
        if echo "$pgname" | grep DBngin &>/dev/null; then
            dbngin_use "$pgversion"
        elif echo "$pgname" | grep MacPorts &>/dev/null; then
            macports_postgresql_use "$pgversion"
        elif echo "$pgname" | grep Herd &>/dev/null; then
            herd_postgresql_use "$pgversion"
        fi
        break;
    done
    pgenv_store
    unset pgVerArr pgversion pgname PS3

}

function switch_postgres_env_vars() {

    if [ $# -eq 1 ]; then
        echo "no support for args in switch_postgres"
        return 0
    fi
    pgenv_set_host
    echo
    pgenv_set_port "${1:-localhost}"
    echo
    pgenv_set_user
    echo

    pgenv_show
    pgenv_store
}


# ------------------------------------------------------------------
# Standard Postgres environment variables -
#   these env vars, along with some custom env var, will be used to control the
#   shell's postgres behaviour, what version, path updates, etc.
#
# PGHOST behaves the same as the host connection parameter.
# PGHOSTADDR behaves the same as the hostaddr connection parameter. This can be set instead of or in addition to PGHOST to avoid DNS lookup overhead.
# PGPORT behaves the same as the port connection parameter.
# PGDATABASE behaves the same as the dbname connection parameter.
# PGUSER behaves the same as the user connection parameter.
# PGPASSWORD behaves the same as the password connection parameter. Use of this environment variable is not recommended for security reasons, as some operating systems allow non-root users to see process environment variables via ps; instead consider using the ~/.pgpass file (see Section 31.15).
# PGPASSFILE specifies the name of the password file to use for lookups. If not set, it defaults to ~/.pgpass (see Section 31.15).
#
# Postgres - align to linux and connect as postgres by default
# ------------------------------------------------------------------

# Aliases
alias pgdbs="psql -l -t | cut -d'|' -f1 | egrep -v 'postgres|template' | xargs"

function dbngin_bin() {
    [ $# -ne 1 ] && {
        echo "Usage: PG_VERSION M.N"
        return 1
    }
    local dbngin_path
    dbngin_path="$(dbngin_path "$1")"
    if [ -z "$dbngin_path" ]; then
        return 1
    fi
    echo "${dbngin_path}/bin"
}

function dbngin_is_pathdefault() {
    [[ $(which pg_restore) =~ .*'/DBngin/'.* ]]
}

function dbngin_json() {
    if [ ! -e "$HOME/Library/Application Support/com.tinyapp.DBngin/Data/DBEngines.plist" ]; then
        return 1
    fi
    plutil -convert json  "$HOME/Library/Application Support/com.tinyapp.DBngin/Data/DBEngines.plist" -o - | jq
}

function dbngin_path() {
    [ $# -ne 1 ] && {
        echo "Usage: PG_VERSION M.N"
        return 1
    }
    ver=$1
    if [ ! -e "$HOME/Library/Application Support/com.tinyapp.DBngin/Data/DBEngines.plist" ]; then
        return 1
    fi
    plutil -convert json  "$HOME/Library/Application Support/com.tinyapp.DBngin/Data/DBEngines.plist" -o - | jq ".[]|select(.Version==\"$ver\")|.Binaries" | xargs
}

function dbngin_port() {
    [ $# -ne 1 ] && {
        echo "Usage: PG_VERSION M.N"
        return 1
    }
    ver=$1
    if [ ! -e "$HOME/Library/Application Support/com.tinyapp.DBngin/Data/DBEngines.plist" ]; then
        return 1
    fi
    plutil -convert json  "$HOME/Library/Application Support/com.tinyapp.DBngin/Data/DBEngines.plist" -o - | jq ".[]|select(.Version==\"$ver\")|.Port" | xargs
}

function dbngin_use() {
    local pgpath
    pgpath=$(dbngin_bin "$1")
    if [ -z "$pgpath" ] && [ -e "$pgpath" ]; then
        return 1
    fi
    export_postgresql_bin_path "$pgpath"
    #export PGPORT=$(dbngin_port $1)
    #export PGHOST=localhost
}


function dbngin_versions() {
    if [ ! -e "$HOME/Library/Application Support/com.tinyapp.DBngin/Data/DBEngines.plist" ]; then
        return 1
    fi
    local versions
    local version
    for version in $(plutil -convert json  "$HOME/Library/Application Support/com.tinyapp.DBngin/Data/DBEngines.plist" -o - | jq '.[]|select(.Type=="PostgreSQL")|.Version' | xargs); do
        if [ -e "$(dbngin_bin "$version")" ]; then
            versions+=("$version")
        fi
    done
    echo "${versions[@]}"
}

function export_postgresql_bin_path() {
    # remove existing postgres clients from PATH
    local CLEAN_PATH
    CLEAN_PATH=$(echo "$PATH" | sed -E 's,/Users/Shared/DBngin/postgresql/[[:digit:]\.]+/bin:,,g')
    CLEAN_PATH=$(echo "$CLEAN_PATH" | sed -E 's,/Users/Shared/Herd/services/postgresql/[[:digit:]\.]+/bin:,,g')
    #CLEAN_PATH=$(echo "$CLEANPATH" | sed -E "s#$(macports_postgresql_bin):##g")
    export PG_CLIENT_PATH="$1"
    export PATH="$PG_CLIENT_PATH:$CLEAN_PATH"

    # set environment as per brew info for the service
    if [ -e "${PG_CLIENT_PATH}"/pg_config ]; then
        local LDFLAGS CPPFLAGS
        LDFLAGS="$LDFLAGS $("$PG_CLIENT_PATH"/pg_config --ldflags)"
        CPPFLAGS="$CPPFLAGS $("$PG_CLIENT_PATH"/pg_config --cppflags)"
        export LDFLAGS CPPFLAGS
    fi

}

function local_postgres_process_ids() {
    # pgrep -ilf 'bin/postgres -D.*-p' # port is specified
    pgrep -ilf 'bin/postgres -D'
}

function local_postgres_pid_name_version_port() {
    # output csv list of postrgres services detected - pid,appname,version,port

    # look for any 'bin/postgres -D' commands in process list
    # pattern match AND pull out matching sections (pid, appname, version, port)
    # final grep , removes any postgres matches that do NOT fit the sed pattern

    local pglist
    pglist="$(pgrep -ilf 'postgres -D' \
        | sed -E 's/^[ ]*([0-9]+).*Shared\/([[:alpha:]]+)\/.*\/([0-9\.]+)\/bin\/postgres -D.* -p ([0-9]+).*/\1,\2,\3,\4/' \
        | grep -v 'sed -E' | grep ',' )"

    if nc -z localhost 5432 &>/dev/null; then
        # find process ID of process Listening on port 5432
        local pgpid
        pgpid="$(netstat -alnv |awk '{print $4","$11}'|sort|uniq|grep '\.5432,'| cut -d',' -f2|uniq|head -1)"
        if [ -n "$pgpid" ]; then
            # assume (look for) macports postgres install.
            local pgpidver
            pgpidver=$(ps -p "$pgpid" -o command | sed 1d | sed -E 's#/opt/local/lib/postgresql([0-9\.]+)/bin/postgres.*#\1#' | sed -E 's/9([0-9])/9.\1/')
            if [ -n "$pgpidver" ]; then
                # append this record to the pglist
                pglist=$(echo -e "$pgpid,macPorts,$pgpidver,5432\n$pglist")
            else
                pglist=$(echo -e "$pgpid,Postgres,unknown,5432\n$pglist")
            fi
        fi
    fi
    echo "$pglist"
}

function local_postgres_choices_show() {
    # local onHost="${1:-${PGHOST:-localhost}}"
    local_postgres_pid_name_version_port | tr , ' ' | awk '{print "PORT "$4" : " $2" v"$3}'
}

function local_postgres_process_ports() {
    # look for any 'bin/postgres -D' commands in process list
    local pids
    pids=$(pgrep -d',' -if 'bin/postgres -D')

    # get command with arguments only ( 1d to remove header)
    # apply any FILTER argument passed as $1
    local pgprocs
    pgprocs=$(ps -p "$pids" -o command | sed 1d)

    local pgports

    # for commands without specified port assume default port of 5432
    if echo "$pgprocs" | grep -v '\-p' &>/dev/null; then
        pgports=(5432)
    fi

    # add any specified ports ( that has been specified with -p argument )
    local scanned_ports
    scanned_ports=$(echo "$pgprocs" | sed -r 's/.* -p ([0-9]+).*/\1/' | grep -Ew '[[:digit:]]+' | sort | uniq)
    # shellcheck disable=SC2206
    pgports+=($scanned_ports)
    echo "${pgports[*]}" | xargs

}

function pgenv_show() {
    echo "# Standard Postgres Env
PGHOST          $PGHOST
PGHOSTADDR      $PGHOSTADDR
PGPORT          $PGPORT
PGDATABASE      $PGDATABASE
PGUSER          $PGUSER
PGPASSWORD      $PGPASSWORD
PGPASSFILE      $PGPASSFILE
# Non Standard Postgres Env
PG_CLIENT_PATH  $PG_CLIENT_PATH
PG95MACHINE     $PG95MACHINE
PG95MODE        $PG95MODE
"
    # listen_addresses = '*' # todo add this the postgresql.conf files.
}

function pgenv_store() {
    pgenv_show | sed -E 's/^(PG[[:alpha:]0-9_]+) +(.+)$/\1=\2/' > "$PGENV"
    cat "$PGENV" | sed -E 's/^(PG[[:alpha:]0-9_]+)=+(.+)$/export \1/' >> "$PGENV"
}


function pgenv_set_port() {
    # PGPORT
    local onHost="${1:-${PGHOST:-localhost}}"

    local pgOptions
    local line port app ver
    pgOptions=();
    for line in $(local_postgres_pid_name_version_port); do
        # validate port - check port is being listened on
        app="$(echo "$line" | cut -d ',' -f2)"
        ver="$(echo "$line" | cut -d ',' -f3)"
        port="$(echo "$line" | cut -d ',' -f4)"
        if nc -z "$onHost" "$port" &>/dev/null; then
            pgOptions+=("$port:$app v$ver");
        fi
    done

    # scan ports possibly... nah
    # nc -z localhost 5432-5532 2>&1 | awk '{print $5}' | xargs

    echo -e "🐘 Set PGPORT\n-------------"
    local pgoption
    COLUMNS=1; select pgoption in "${pgOptions[@]}"; do
        echo "$pgoption"
        PGPORT=$(echo "$pgoption"|cut -d':' -f1)
        break
    done

    export PGPORT
    pgenv_store
    unset pgOptions PS3 pgPorts pgoption
}

# shellcheck disable=SC2048
function pgenv_set_host() {
    # PGHOST
    local pgOptions
    pgOptions=(localhost)

    if type orbctl &>/dev/null; then
        # collect orb linux machine names
        local machine
        for machine in $(orbctl list -f json | jq '.[]|.name' | tr -d '"'| xargs -o printf -- '%s.orb.local '); do
            pgOptions+=("$machine")
        done
    else
        echo "${RED}missing orbctl${NC}"
    fi

    echo -e "🐘 Set PGHOST\n-------------"
    #PS3="🐘 Set PGHOST: "
    local pgoption
    COLUMNS=1; select pgoption in ${pgOptions[*]}; do
        PGHOST=$pgoption
        break
    done

    export PGHOST
    pgenv_store
    unset PS3 pgOptions pgoption
}

function pgenv_set_user() {
    # PGUSER
    echo -e "🐘 Set PGUSER\n-------------"
    #PS3="🐘 Set PGUSER: "
    local pgoption
    COLUMNS=1; select pgoption in postgres homestead $(whoami) vagrant; do
        PGUSER=$pgoption
        break
    done
    export PGUSER
    pgenv_store
    unset PS3 pgOptions pgoption
}

function herd_postgresql_bin() {
    local pgversion="*${1/:-/}"

    if find /Users/Shared/Herd/services/postgresql -path "$pgversion/bin/psql" &>/dev/null; then
        find /Users/Shared/Herd/services/postgresql -path "$pgversion/bin" | sort | tail -1
        return
    fi
    return 1
}

function herd_postgresql_is_pathdefault() {
    # better check for pg_restore (rather that psql) as Laravel Herd places psql in the PATH explicitly via symlink (but not other client tools).
    [[ $(which pg_restore) =~ .*'/Herd/'.* ]]
}

function herd_postgresql_port() {
    local check_file
    check_file=$(ls /Users/Shared/Herd/services/postgresql/*/bin/psql)
    for hpgv in $(dirname "$(dirname "${check_file}")"); do basename "$hpgv"; done | xargs
}

function herd_postgresql_use() {
    local pgpath
    pgpath=$(herd_postgresql_bin "$1")
    if [ -z "$pgpath" ]; then
        return 1
    fi
    # remove existing postgresql from the path
    export_postgresql_bin_path "$pgpath"
    #export PGPORT=$(herd_port $1)
}

function herd_postgresql_versions() {
    local check_file
    check_file=$(ls /Users/Shared/Herd/services/postgresql/*/bin/psql)
    for hpgv in $(dirname "$(dirname "$check_file")"); do basename "$hpgv"; done | xargs
}

function herd_postgresql_versions_running() {
    local_postgres_pid_name_version_port | grep Herd | cut -d, -f3 | xargs
}

function macports_postgresql95_install() {
    if type port &>/dev/null && ! port &>/dev/null; then
        echo "http https://github.com/macports/macports-base/releases/download/v2.10.1/MacPorts-2.10.1-15-Sequoia.pkg; open MacPorts-2.10.1-15-Sequoia.pkg"
    fi
    sudo port install postgresql95-server
    local _pgsecret
    read -rp "Enter postgresql password for $(whoami) " _pgsecret
    sudo -u postgres psql -c "CREATE ROLE $(whoami) LOGIN PASSWORD '$_pgsecret' SUPERUSER INHERIT;"
}

function macports_postgresql95_is_pathdefault() {
    # better check for pg_restore (rather that psql) as
    # Laravel Herd places psql in the PATH explicitly via symlink (but not other client tools).
    [[ $(which pg_restore) =~ '/opt/local/lib/postgresql95/bin/pg_restore' ]]
}

function macports_postgresql95_is_installed() {
    [ -f /opt/local/lib/postgresql95/bin/psql ]
}

function macports_postgresql_bin() {
    local macport
    local version
    version="$(echo "${1:-95}"| tr -d  "[:alpha:]-_." )"

    if macport="$(port -q contents postgresql"${version}" 2>/dev/null | grep 'pg_restore$')"; then
        dirname "$macport" | xargs
        return $?
    fi
    return 1
    #dirname "$(port -q contents postgresql"${1:-95} 2>/dev/null" | grep 'pg_restore$')" | xargs
}

function macports_postgresql_path() {
    dirname "$(macports_postgresql_bin "$1")"
}

function macports_postgresql_use() {
    local pgpath
    pgpath=$(macports_postgresql_bin "$1")
    if [ -z "$pgpath" ]; then
        return 1
    fi
    export_postgresql_bin_path "$pgpath"
    #export PGPORT=$(macports_port $1)
}

function macports_postgresql_versions() {
    if type port &>/dev/null; then
        port -q installed "postgresql*-server" | cut -d'-' -f1
    fi
}


function pg95_mode() {
    # set pg95 alaises

    # PG95MODE - macports, orbstack

    local mode="${1}"

    if [[ "$mode" =~ "orb".* ]]; then

        export PG95MODE='orbstack'
        export PG95MACHINE="${PG95MACHINE:-postgres95}"

        alias pg95_start='orbctl -m $PG95MACHINE run systemctl start postgresql || echo PG95MACHINE=$PG95MACHINE'
        alias pg95_stop='orbctl -m $PG95MACHINE run systemctl stop postgresql || echo PG95MACHINE=$PG95MACHINE'
        alias pg95_restart='orbctl -m $PG95MACHINE run systemctl restart postgresql || echo PG95MACHINE=$PG95MACHINE'
        alias pg95_status='orbctl -m $PG95MACHINE run systemctl status postgresql || echo PG95MACHINE=$PG95MACHINE'

    else
        export PG95MODE='macports'

        # mac ports aliases - see sudo port install postgresql95-server
        alias pg95_start='sudo port load postgresql95-server'
        alias pg95_stop='sudo port unload postgresql95-server'
        alias pg95_restart='sudo port reload postgresql95-server'

        # use lunchy ( the launchctl helper ) to control launchd mac port service
        alias pg95_start='sudo lunchy start org.macports.postgresql95-server'
        alias pg95_stop='sudo lunchy stop org.macports.postgresql95-server'
        alias pg95_restart='sudo lunchy restart org.macports.postgresql95-server'
        alias pg95_status='sudo lunchy status org.macports.postgresql95-server;sudo lunchy show org.macports.postgresql95-server'

    fi

    #echo -e "🐘 Postgresql scripts loaded (9.5 mode '$PG95MODE' [$PGHOST:$PGPORT - $PGUSER] )"
    echo -e "🐘 ${YELLOW}${BOLD}Postgresql scripts loaded${NC} - ${GREEN}see switch_postgres and pgenv_show${NC}"

}

function pghashlib_install() {

    local PG_PORT
    PG_PORT="${PGPORT:-5432}"
    local dbngin_choice

    if herd_postgresql_is_pathdefault; then
        echo "${RED}Using HERD${NC}"
        # Herd uses a signed postgres binary that stops custom built extensions loading.
        # Until Herd allows custom extensions, we unsign it (seems to work) to allow custom built extensions to load and run.
        # confirm codesign -d --verbose=4  /Users/Shared/Herd/services/postgresql/17/bin/postgres 2>&1| grep 'Authority=.*Beyond Code' &>/dev/null
        local postgres_bin="$(herd_postgresql_bin)/postgres"
        if [ -e "$postgres_bin" ]; then
            if codesign -d -v "$postgres_bin" 2>&1 | grep -v 'not signed at all' &>/dev/null; then
                echo "The postgres binary '$postgres_bin' needs to be UnSigned and restarted before building the pghashlib !! "
                # remove strict code signing for
                if ! codesign --remove-signature "$postgres_bin"; then
                    echo "${RED}Unable to remove signature from $postgres_bin ! Cannot load custom extensions.${NC}"
                    return 2
                fi
                echo "${RED}Signature has been removed from $postgres_bin, MANUALLY restart this Herd postgres service.${NC}"
                return 1
            fi
        fi
    fi

    if dbngin_is_pathdefault && [ -n "$(dbngin_versions)" ]; then
        echo "DBngin PostgreSQL appears to be installed, the following versions are available ($(dbngin_versions))."
        read -rp "Install against a DBngin PostgreSQL version or continue with default path (Enter for default)" dbngin_choice
        if [ -n "$dbngin_choice" ]; then
            echo "Temporarily setting PATH and PG_PORT for DBngin $dbngin_choice".
            PATH="$(dbngin_path "$dbngin_choice")/bin:$PATH"
            PG_PORT=$(dbngin_port "${dbngin_choice}")
            export PATH PG_PORT
        else
            echo "Continuing on with default postgres version"
        fi
    fi


    # alternative
    #   - https://github.com/Cyan4973/xxHash
    #   - https://github.com/hatarist/pg_xxhash
    #   - https://github.com/fboulnois/pg_uuidv7
    #   - https://github.com/petere/pgvihash

    # extensions
    # https://gist.github.com/joelonsql/e5aa27f8cc9bd22b8999b7de8aee9d47
    # https://docs.digitalocean.com/products/databases/postgresql/details/supported-extensions/
    #

    pgenv_show

    if ! type -a rst2html &>/dev/null; then
        HOMEBREW_NO_INSTALL_CLEANUP=true HOMEBREW_NO_INSTALL_UPGRADE=true \
            brew install docutils # provides rst2html command
    fi
    pushd /tmp && \
    wget --quiet https://github.com/markokr/pghashlib/archive/master.zip -O pghashlib.zip && \
    echo "unzip" && unzip -o pghashlib.zip &>/dev/null && \
    pushd pghashlib-master && \
    echo "hashlib install" && \
#    if [ -e "$(find "$(pg_config --includedir)" -name 'varatt.h')" ]; then
#        local line
#        # postgres 16+ fails for phhashlib
#        # build failure on postgres16 - https://stackoverflow.com/questions/77617997/how-to-set-varsize-and-set-varsize-in-postgresql-16
#        # append after match #include <fmgr.h> - src/pghashlib.h
#        line=$(grep -n '#include <fmgr.h>' src/pghashlib.h | cut -d: -f1)
#        sed -i '' "${line}s/^/#include <varatt.h>\n/" src/pghashlib.h
#    fi &&
    echo "make" && make &>/dev/null && \
    env | grep -Ei 'PG_' && \
    echo "make install" && {
        touch "$(pg_config --libdir)"/test ||
        sudo make install &>/dev/null &&
        make install &>/dev/null
    } && \
    echo "hashlib done"

    popd && \
    echo "Tidyup hashlib" && \
    [ -e pghashlib-master ] && rm -rf pghashlib-master && \
    echo "done"
    popd || return

    local POSTGRESUSER='postgres'
    psql -U "$(whoami)" -p "$PG_PORT" -c "create role $POSTGRESUSER superuser login password '';" &>/dev/null || true

    if herd_postgresql_is_pathdefault; then
        # sign the newly built extension
        codesign -s- $(pg_config --libdir)/hashlib.dylib

        echo "${RED}Removed signature from $postgres_bin ! Try to load custom extensions.${NC}"
        codesign -d -v "$postgres_bin"
        echo "Reloading postgres configuration"
        psql -c "SELECT pg_reload_conf();"
    else
        echo "${RED}NOT Using HERD${NC}"
    fi

    psql -U "$POSTGRESUSER" -p "$PG_PORT" -c "drop extension hashlib" &>/dev/null || true
    psql -U "$POSTGRESUSER" -p "$PG_PORT" -c "create extension hashlib";
    if [ "$(psql -U "$POSTGRESUSER" -p "$PG_PORT" -t -c "select encode(hash128_string('abcdefg', 'murmur3'), 'hex');" | head -1 | awk '{print $1}')" == '069b3c88000000000000000000000000' ]; then
        echo 'pghashlib installed correctly'
    else
        echo 'pghashlib not installed correctly'
    fi
    psql -U postgres -p "$PG_PORT" -c '\dx'

}

#
# Load PG ENV settings
# setup environment and path for any saved postgresql settings
#
export PGENV="$HOME/.pgenv"
if [ -f "$PGENV" ]; then
    # shellcheck disable=SC1090
    source "$PGENV"
    # Postgres - align to linux and connect as postgres by default
    if eval false; then
        # not used... here as reference to Brew postgresql installs
        if test -e /usr/local/opt/postgresql@${PGVERSION}; then
            export PATH="/usr/local/opt/postgresql@${PGVERSION}/bin:$PATH"
            export LDFLAGS="-L/usr/local/opt/postgresql@${PGVERSION}/lib"
            export CPPFLAGS="-I/usr/local/opt/postgresql@${PGVERSION}/include"
        fi
    fi
fi

pg95_mode "${PG95MODE:-orbstack}" #orbstack, macports
if [ -n "$PG_CLIENT_PATH" ] && [ -f "${PG_CLIENT_PATH}/psql" ]; then
    export_postgresql_bin_path "$PG_CLIENT_PATH"
fi



