QWER_PS1_DIR="${QWER_PS1_DIR:-${HOME}/.qwer-ps1}"
QWER_PS1_SHIMS="${QWER_PS1_DIR}/shims"
QWER_PS1_PLUGINS="${QWER_PS1_DIR}/plugins"
mkdir -p ${QWER_PS1_SHIMS}
mkdir -p ${QWER_PS1_PLUGINS}


_qwer_ps1_usage() {
  echo "usage:   qwer-ps1 <options> show-current <name>        -- show current value of <name>" >&2
  echo "         qwer-ps1           plugin add <name> <url>    -- add plugin" >&2
  echo "         qwer-ps1           plugin list                -- list all installed plugin" >&2
  echo "         qwer-ps1           plugin update <name>       -- update plugin" >&2
  # echo "         qwer-ps1           plugin update (--all)" >&2
  echo "         qwer-ps1           plugin remove <name>       -- remove plugin" >&2
  echo "         qwer-ps1           plugin is-installed <name> -- check whether the plugin is installed" >&2
  echo "         qwer-ps1           init                       -- function to initialize qwer-ps1 and plugins" >&2
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

  if [[ ! -f "${QWER_PS1_SHIMS}/show-current-${name}" ]]; then
    if [[ $fail == 'true' ]]; then
      echo "Error: plugin $name not found." >&2
      return 1
    else
      echo ''
      return 0
    fi
  fi

  local result="$(. ${QWER_PS1_SHIMS}/show-current-${name})"
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
    :
  else
    _qwer_ps1_show_current_core "$@"
  fi
}

_qwer_ps1_plugin_add() {
  local name="$1"
  local url="$2"

  git clone $url ${QWER_PS1_PLUGINS}/${name}
  echo
  if [[ ! -f ${QWER_PS1_PLUGINS}/${name}/src/show-current ]]; then
    echo "${QWER_PS1_PLUGINS}/${name}/src/show-current not found. Invalid qwer-ps1 plugin..." >&2
    return 1
  fi

  _qwer_ps1_plugin_link $name
}

_qwer_ps1_plugin_link() {
  local name="$1"

  if [[ ! -f ${QWER_PS1_SHIMS}/show-current-${name} ]]; then
    echo "Linking ${QWER_PS1_PLUGINS}/${name}/src/show-current ..."
    ln -s ${QWER_PS1_PLUGINS}/${name}/src/show-current ${QWER_PS1_SHIMS}/show-current-${name}
  fi

  if [[ -f ${QWER_PS1_PLUGINS}/${name}/src/init && ! -f ${QWER_PS1_SHIMS}/init-${name} ]]; then
    echo "Linking ${QWER_PS1_PLUGINS}/${name}/src/init ..."
    ln -s ${QWER_PS1_PLUGINS}/${name}/src/init ${QWER_PS1_SHIMS}/init-${name}
  fi
}

_qwer_ps1_plugin_list() {
  find ${QWER_PS1_SHIMS} -name show-current-* | tr ' ' '\n' | sed 's;.*show-current-;;'
}

_qwer_ps1_plugin_update() {
  local name="$1"

  if [[ -d ${QWER_PS1_PLUGINS}/${name} ]]; then
    pushd ${QWER_PS1_PLUGINS}/${name}
    git pull
    echo
    _qwer_ps1_plugin_link $name
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

_qwer_ps1_plugin_is_installed() {
  local name="$1"
  [[ -f ${QWER_PS1_SHIMS}/show-current-${name} ]]
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
    is-installed | ii)
      _qwer_ps1_plugin_is_installed "$@"
      ;;
    *)
      echo "Error: unknown subcommand '$subcmd' specified" >&2
      _qwer_ps1_usage
      ;;
  esac
}

_qwer_ps1_init() {
  cat <<EOS
if which add-zsh-hook &>/dev/null && [[ $QWER_PS1_LAZY_LOADING == 'true' ]]; then
  _qwer_init_precmd_tmp() {
    unset _qwer_init_precmd_tmp
    _qwer_init_precmd_tmp() {
      QWER_PS1_LAZY_LOADING='false'
      add-zsh-hook -d precmd _qwer_init_precmd_tmp
    }
  }
  add-zsh-hook precmd _qwer_init_precmd_tmp
fi
EOS
}

qp1() {
  qwer-ps1 "$@"
}

qwer-ps1() {
  if [[ $# -lt 1 ]]; then
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
    init)
      _qwer_ps1_init
      ;;
    *)
      echo "Error: unknown subcommand '$subcmd' specified" >&2
      _qwer_ps1_usage
      ;;
  esac
}
