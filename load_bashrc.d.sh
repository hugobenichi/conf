
# load any supplementary scripts
for config in "$HOME"/.bashrc.d/*; do
  source "$config"
done
unset -v config
