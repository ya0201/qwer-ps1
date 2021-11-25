QWER_PS1_DIR="${QWER_PS1_DIR:-${HOME}/.qwer-ps1}"
QWER_PS1_SHIMS="${QWER_PS1_DIR}/shims"
QWER_PS1_PLUGINS="${QWER_PS1_DIR}/plugins"
mkdir -p ${QWER_PS1_SHIMS}
mkdir -p ${QWER_PS1_PLUGINS}


_qwer_ps1_usage() {
  echo "usage:   qwer-ps1 <options> show-current <name>" >&2
  echo "         qwer-ps1           plugin add <name> <url>" >&2
  echo "         qwer-ps1           plugin list" >&2
  echo "         qwer-ps1           plugin update <name>" >&2
  # echo "         qwer-ps1           plugin update (--all)" >&2
  echo "         qwer-ps1           plugin remove <name>" >&2
  echo "" >&2
  echo "options: -b <brackets pair (default: '[]')> -- brackets you want to use" >&2
  echo "         -c <color (default: 'red')>        -- color you want to use" >&2
  echo "         -f (default: 'false')              -- fails if plugin not found or returned empty string" >&2
}

_qwer_ps1_show_current_core() {
  local brackets="$1"
  local color="$2"
  local fail="$3"
  local name="$4"

  if [[ ! -x "${QWER_PS1_SHIMS}/show-current-${name}" ]]; then
    if [[ $fail == 'true' ]]; then
      echo "Error: plugin $name not found." >&2
      return 1
    else
      echo ''
      return 0
    fi
  fi

  local result="$(${QWER_PS1_SHIMS}/show-current-${name})"
  if [[ -n "$result" ]]; then
    local left=${brackets:0:1}
    local right=${brackets:1:1}
    echo "%{${fg[$color]}%}${left}${result}${right}%{${reset_color}%}"
    return 0
  elif [[ $fail == 'true' ]]; then
    echo "Error: could not show current $name value." >&2
    return 1
  else
    echo ''
    return 0
  fi
}

# wrap _qwer_ps1_show_current_core for lazy loading
_qwer_ps1_show_current() {
  if [[ "$QWER_PS1_LAZY_LOADING" == 'true' ]]; then
    ## lazy loading
    unset -f _qwer_ps1_show_current
    _qwer_ps1_show_current() {
      _qwer_ps1_show_current_core "$@"
    }
  else
    _qwer_ps1_show_current_core "$@"
  fi
}

_qwer_ps1_plugin_add() {
  local name="$1"
  local url="$2"

  git clone $url ${QWER_PS1_PLUGINS}/${name}
  ln -s ${QWER_PS1_PLUGINS}/${name}/bin/show-current ${QWER_PS1_SHIMS}/show-current-${name}
}

_qwer_ps1_plugin_list() {
  ls ${QWER_PS1_SHIMS}/show-current-* | tr ' ' '\n' | sed 's;.*show-current-;;'
}

_qwer_ps1_plugin_update() {
  local name="$1"

  if [[ -d ${QWER_PS1_PLUGINS}/${name} ]]; then
    pushd ${QWER_PS1_PLUGINS}/${name}
    git pull
    popd
  else
    echo "Plugin $name not installed." >&2
    return 1
  fi
}

_qwer_ps1_plugin_remove() {
  local name="$1"

  if [[ -z $name ]]; then
    echo "Please specify plugin name." >&2
    return 1
  elif [[ -d ${QWER_PS1_PLUGINS}/${name} ]]; then
    unlink ${QWER_PS1_SHIMS}/show-current-${name}
    rm -rf ${QWER_PS1_PLUGINS}/${name}
  else
    echo "Plugin $name not installed." >&2
    return 1
  fi
}

_qwer_ps1_plugin() {
  local subcmd="$1"
  shift

  case $subcmd in
    add | a)
      _qwer_ps1_plugin_add "$@"
      ;;
    list | l)
      _qwer_ps1_plugin_list
      ;;
    update | u)
      _qwer_ps1_plugin_update "$@"
      ;;
    remove | r)
      _qwer_ps1_plugin_remove "$@"
      ;;
    *)
      echo "Error: unknown subcommand '$subcmd' specified" >&2
      _qwer_ps1_usage
      ;;
  esac
}

qp1() {
  qwer-ps1 "$@"
}

qwer-ps1() {
  if [[ $# -lt 2 ]]; then
    _qwer_ps1_usage
    return 1
  fi

  local opt
  local brackets='[]'
  local color='red'
  local fail='false'
  while getopts b:c:fh opt; do
    case "$opt" in
      b)
        brackets="$OPTARG"
        ;;
      c)
        color="$OPTARG"
        ;;
      f)
        fail='true'
        ;;
      h)
        _qwer_ps1_usage
        return 0
        ;;
      \?)
        _qwer_ps1_usage
        return 1
        ;;
    esac
  done
  shift $((OPTIND - 1))


  local subcmd="$1"
  shift

  case $subcmd in
    show-current | s)
      _qwer_ps1_show_current "$brackets" "$color" "$fail" "$@"
      ;;
    plugin | p)
      _qwer_ps1_plugin "$@"
      ;;
    *)
      echo "Error: unknown subcommand '$subcmd' specified" >&2
      _qwer_ps1_usage
      ;;
  esac
}