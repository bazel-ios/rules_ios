wrapped_bazelisk() {
  if [[ "$(arch)" != "x86_64" ]]; then
    arch -arch x86_64 bazelisk "$@"
  else
    bazelisk "$@"
  fi
}

export -f wrapped_bazelisk