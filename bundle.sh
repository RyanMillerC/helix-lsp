#!/bin/bash

set -e

# Version is the year, month, and date in format: 2024.4.4
VERSION=$(date '+%Y.%-m.%-d')

# Wipe out existing directory, if it exists
[[ -d "$VERSION" ]] && rm -rf "$VERSION"
mkdir "$VERSION"
mkdir "$VERSION/binary"
mkdir "$VERSION/python"
mkdir "$VERSION/npm"

# Just in case
[[ -d ./tmp ]] && rm -rf ./tmp

main() {
  # Ansible
  with_npm '@ansible/ansible-language-server'

  # Bash
  with_npm 'bash-language-server'

  # CSS, JSON, HTML
  with_npm 'vscode-langservers-extracted'

  # Docker
  with_npm 'dockerfile-language-server-nodejs'

  # Helm
  with_curl https://github.com/mrjosh/helm-ls/releases/latest/download/helm_ls_windows_amd64.exe helm_ls.exe

  # Make
  with_pip 'cmake-language-server'

  # Markdown
  with_curl https://github.com/artempyanykh/marksman/releases/latest/download/marksman.exe marksman.exe
  with_curl https://github.com/valentjn/ltex-ls/releases/download/16.0.0/ltex-ls-16.0.0-windows-x64.zip ltex-ls.exe

  # Python
  with_npm 'pyright'
  with_pip 'black'
  with_pip 'pylsp-mypy'
  with_pip 'python-lsp-ruff'
  with_pip 'python-lsp-server[all]'
  with_pip 'ruff'
  with_pip 'ruff-lsp'
 
  # Terraform HCL
  with_curl https://releases.hashicorp.com/terraform-ls/0.33.0/terraform-ls_0.33.0_windows_amd64.zip terraform-ls.zip

  # YAML
  with_npm 'yaml-language-server@next'
}

# Download a file with curl
with_curl() {
  URL="$1"
  FILE_NAME="$2"

  echo "Downloading $FILE_NAME binary file with curl..."
  curl -L -s -o "$VERSION/binary/$FILE_NAME" "$URL"
}

# Download a NodeJS package with npm
with_npm() {
  PACKAGE_NAME="$1"

  echo "Downloading $PACKAGE_NAME with npm..."
  npm install -g --prefix ./tmp "$PACKAGE_NAME"
  cd "./tmp/node_modules/$PACKAGE_NAME"
  yarn pack
  cd -
  cp "./tmp/node_modules/$PACKAGE_NAME/${PACKAGE_NAME}-*.tgz" "$VERSION/npm"
}

# Download a Python package with pip
with_pip() {
  PACKAGE_NAME="$1"

  echo "Downloading $PACKAGE_NAME with pip..."
  cd "$VERSION/python"
  pip download --prefer-binary "$PACKAGE_NAME"
  cd -
}

# Load script
main
