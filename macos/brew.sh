# Update howebrew (casks and packages)
brew update
brew upgrade

# install all dependencies contained in ./Brewfile
echo "[brew] installing the casks..."
brew bundle