# qwer-ps1
This is too simple, highly extendable manager for your $PROMPT. Inspired by [asdf](https://github.com/asdf-vm/asdf).

## requirements
- zsh
- git

## usage
```shell
# install qwer-ps1 itself
git clone https://github.com/ya0201/qwer-ps1 /path/you/want/to/clone
echo "source /path/to/qwer-ps1.zsh" >> ${HOME}/.zshrc

# add plugin
qwer-ps1 plugin add oscloud https://github.com/ya0201/qwer-ps1-oscloud

# use plugin to show oscloud in your $PROMPT
echo 'PROMPT=${PROMPT}'\''$(qwer-ps1 show-current oscloud)'\' >> ${HOME}/.zshrc
```

or, you can write like this in your .zshrc
```shell
# qwer-ps1
source /path/to/qwer-ps1.zsh
if ! qp1 p ii oscloud; then
  qp1 p a oscloud https://github.com/ya0201/qwer-ps1-oscloud
fi
PROMPT=${PROMPT}'$(qp1 s oscloud)'
```

## customize
By default, qwer-ps1 use '[]' and red. So, if you write like this :arrow_down:
```shell
source /path/to/qwer-ps1.zsh
if ! qp1 p ii oscloud; then
  qp1 p a oscloud https://github.com/ya0201/qwer-ps1-oscloud
fi
PROMPT='$(qp1 s oscloud) '${PROMPT}
```
then it appears like this :arrow_down:  
<img width="362" alt="スクリーンショット 2021-11-25 23 00 29" src="https://user-images.githubusercontent.com/23146443/143455675-6767ad51-c26f-4f04-a568-eadb63a76b77.png">

  
  
You can customize this behavior using -b (brackets) and -c (color) option.
```diff
source /path/to/qwer-ps1.zsh
if ! qp1 p ii oscloud; then
  qp1 p a oscloud https://github.com/ya0201/qwer-ps1-oscloud
fi
- PROMPT='$(qp1 s oscloud) '${PROMPT}
+ PROMPT='$(qp1 -b {} -c yellow s oscloud) '${PROMPT}
```
<img width="368" alt="スクリーンショット 2021-11-25 23 02 50" src="https://user-images.githubusercontent.com/23146443/143455711-61c73273-01c7-47a2-9bf5-d6517f2d54d9.png">
