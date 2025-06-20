#!/bin/bash

# Script para desinstalar o plugin manai-vim
echo "Desinstalando manai-vim..."

# Remove a configuração do vimrc
clean_vimrc() {
  local vimrc_file="$HOME/.vimrc"
  local nvim_dir="$HOME/.config/nvim"
  
  if [ -n "$(which nvim)" ]; then
    if [ -f "$nvim_dir/init.vim" ]; then
      vimrc_file="$nvim_dir/init.vim"
    fi
  fi

  if [ -f "$vimrc_file" ]; then
    echo "Removendo configuração de $vimrc_file..."
    sed -i '/^" Configuração do manai-vim/,/^let g:manai_theme/d' "$vimrc_file"
  fi
}

# Remove o plugin
uninstall_plugin() {
  if [ -n "$(which nvim)" ]; then
    echo "Removendo plugin do Neovim..."
    nvim +PlugClean! +qall
  else
    echo "Removendo plugin do Vim..."
    vim +PlugClean! +qall
  fi
}

# Remove arquivos de configuração (opcional)
remove_config() {
  read -p "Deseja remover os arquivos de configuração em ~/.config/manai? [y/N] " choice
  case "$choice" in
    y|Y ) 
      echo "Removendo arquivos de configuração..."
      rm -rf "$HOME/.config/manai"
      ;;
    * ) 
      echo "Arquivos de configuração mantidos."
      ;;
  esac
}

# Fluxo principal
clean_vimrc
uninstall_plugin
remove_config

echo "Desinstalação completa!"