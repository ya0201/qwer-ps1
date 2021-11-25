# qwer-ps1
This is too simple, highly extendable manager for your $PROMPT.

## requirements
- zsh
- git

## usage
```shell
# install qwer-ps1 itself
git clone https://github.com/ya0201/qwer-ps1 /path/you/want/to/clone
echo "source /path/to/qwer-ps1.zsh" >> .zshrc

# add plugin
qwer-ps1 plugin add oscloud https://github.com/ya0201/qwer-ps1-oscloud

# use plugin to show oscloud in your $PROMPT
echo "PROMPT=${PROMPT}'$(qwer-ps1 -b {} -c red show-current oscloud)'" >> .zshrc
```
