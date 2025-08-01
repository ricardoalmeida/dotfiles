# Update howebrew (casks and packages)
brew update
brew upgrade

# install all dependencies contained in ./Brewfile
echo "[brew] installing the casks..."
brew bundle

# install global npm packages
echo "[npm] installing global packages..."
npm install -g @anthropic-ai/claude-code
npm install -g tldr
