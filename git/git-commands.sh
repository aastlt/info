

# Подсветка в .bashrc

https://github.com/magicmonty/bash-git-prompt

# Альтернативный вариант
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$(parse_git_branch)\[\033[00m\] $ "

git init

# Статус репозитория
git status

# Свойства пользователя
git config --global user.name "first_name last_name"
git config --global user.email email@domain

# Редактор (необязательно)
git config --global core.editor nano

# Добавление в индекс (stage)
git add testfile

# Просмотр проиндексированных изменений
git diff --cached

# Удаление из индекса (stage)
git rm --cached testfile

# Удаление файла (совсем)
git rm testfile

# Добавить всё
git add -A

# Список коммитов
git log




git status

# Список коммитов
git log
git log --graph
git log --graph --oneline

# Информация о последнем коммите
git show

# Информация о конкретном коммите
git show [commit_id]

# Вернуть состояние на [commit_id]
git checkout [commit_id]

# Загрузить состояние последнего коммита ветки master
git checkout master

# Редактируем файл
echo "Test new git commit" >> file.txt

# Смотрим, что изменилось
git diff

# Проиндексированные изменения
git diff --cached

# Фиксируем изменения
git commit -am "String added!"

# Смотрим историю
git log
#######################################################
################### GitHub ############################
#######################################################

# Новый репозиторий - подключить к GitHub
echo "# otus_test" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:Nickmob/otus_test.git
git push -u origin main

# Залить сщуествующий репозиторий в GitHub
git remote add origin git@github.com:Nickmob/otus_test.git
git branch -M main
git push -u origin main

# Делаем ключ для репозитория
ssh-keygen

cat ~/.ssh/id_rsa.pub

https://github.com/settings/keys

########################################################
# Работа с ветками
git branch feature

# Создание и переход в ветку одной командой
git checkout -b new

git branch

# Переходим в неё
git checkout feature

#
git checkout master

git add .

git commit -m 'Add new file1'

# Выливка изменений на Github
git push origin master

git remote -v

# Сливаем измнения между ветками с конфликтом
git pull

git checkout feature

git merge master

nano test

git add .

git merge master

git checkout master

git merge feature

git push origin master

git checkout feature

# Выливаем ветку в Github
git push -u origin feature

# Откат изменений
git revert [commit ID 7 first chars]

# Создать ветку от кокретного коммента
git checkout -b feature2 [commit ID 7 first chars]

cd .git/hooks
cat > pre-commit
#!/bin/bash

echo "Hello buddy!!!"

chmod +x pre-commit








