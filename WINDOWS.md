Using Git on Windows at Work
============================

1. Install msysGit: http://code.google.com/p/msysgit/downloads/list
2. Setup ssh: http://help.github.com/win-set-up-git/
3. Setup proxy in git config globally:

git config --global http.proxy http://proxy:8080    # create
git config --get http.proxy                         # check
# git config --global --unset http.proxy            # delete entry

# test
curl http://google.com
# should result in some html code


Links
-----
Git Setup:    http://help.github.com/win-set-up-git/
Git Tutorial: http://www.vogella.de/articles/Git/article.html#remote_proxy

