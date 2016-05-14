# simplest-git-subrepos

The simplest way to manage git repos within git repos.

##### Table of Contents

* [the long explanation](#the_long_explanation)  
* [the use case](#the_use_case)
* [the solution](#the_solution)
* [going forward](#going_forward)

<a name="the_long_explanation"/>  
## the long explanation

It is [quite a common desire](https://www.google.es/search?q=git+repos+within+git+repos) to somehow have git repositories within git repositories<sup name="fe1">[[1]](#fn1)</sup>.  The typical answers involve convoluted incantations of [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) (with [the usual word of caution about them](https://codingkilledthecat.wordpress.com/2012/04/28/why-your-company-shouldnt-use-git-submodules/)), [git-subtree](https://github.com/git/git/blob/master/contrib/subtree/git-subtree.txt) (which is [_oh, so much easier!_](https://developer.atlassian.com/blog/2015/05/the-power-of-git-subtree/?_ga=1.267682510.1986266707.1461346777)), or even specifically crafted tools to deal with the complexity of those<sup name="fe1">[[2]](#fn2)</sup>.

In the end, the point is that something that sounds like it should be easy ends up being complex and -the worse of it, error prone.

But, **_does it need to be so complex?_**

The naive approach (_my_ naive approach at least) would be _...well, why not just dropping a git repo within another git repo?_  Much to my surprise after a long search on Google without results, that's not only perfectly possible, but trivially easy indeed, and basically without any bad side effect.

After such a _"discovery"_ I decided to share publicly by example in case others find it of benefit.

<a name="the_use_case"/>  
## the use case

It seems that the motto _"make easy things easy and hard things possible"_ can be tracked down to [Larry Wall](https://www.wikipedia.org/wiki/Larry_Wall) and ["Learning Perl"](http://shop.oreilly.com/product/9781565922846.do), aka _the Llama book_.  I'm not telling submodules, subtrees, all those tools... are not without merit but I do say they fail Wall's saying: they certainly fail at making easy things easy.  But, what I want to suit then?

Let's have a project which I'll call **_SUPER_** which have some glue files in order to tie together another two ones which I'll call **_SUB1_** and **_SUB2_** (you can think of, say, a web front end using two modules, or whatever).  Just to make things funnier, let's imagine that **_SUB1_** also includes a deeper module, which I'll call **_SUBSUB_**.  Overall, the layout looks like this:

    [SUPER]|README.md
           |
           |[SUB1]|file1
           |      |
           |      |[SUBSUB]|another_file
           |
           |[SUB2]|file2

Now, if I merely _consume_ the contents of **_SUB1_** and **_SUB2_** (and, of course, **_SUBSUB_**), using _vendor branches_ or just bringing them at build time from an artifacts repository would be good enough but, what if I want/need to also contribute to all of them?  Typically that's the case for corporate environments, where all those repositories belong to the same owner (the company) and the _"proper"_ way to test and evolution the submodules is by calling them from the parent one (or another similar one for testing purposes).  So, to recall the situation:  

1. The functionallity of the submodules can only be ascertained (at least comfortably) by means of their integration with the **_SUPER_** one.
2. I have write access to at least some branches on the submodules.

<a name="the_solution"/>  
## the solution

As I already said above, why not try to just create a git repo within another?  So let's do it:
```
jmnavarrol@:~/super$ git init
Initialized empty Git repository in ~/super/.git/
jmnavarrol@:~/super$ echo 'Hello, World!' > README.txt
jmnavarrol@:~/super$ git add README.txt
jmnavarrol@:~/super$ git commit -m "first commit"
[master (root-commit) 5677966] first commit
 1 file changed, 1 insertion(+)
 create mode 100644 README.txt
jmnavarrol@:~/super$
```

Now, let's go for the second one:
```
jmnavarrol@:~/super$ mkdir sub1 && cd sub1
jmnavarrol@:~/super/sub1$ git init
Initialized empty Git repository in ~/super/sub1/.git/
jmnavarrol@:~/super/sub1$ echo 'The sub1 repo' > file1
jmnavarrol@:~/super/sub1$ git add file1
jmnavarrol@:~/super/sub1$ git commit -m "first commit into the sub1 repo"
[master (root-commit) 1f8273f] first commit into the sub1 repo
 1 file changed, 1 insertion(+)
 create mode 100644 file1
jmnavarrol@:~/super/sub1$
```

So, how is the world seen from the **_SUB1_** repo?
```
jmnavarrol@:~/super/sub1$ git checkout -b development
Switched to a new branch 'development'
jmnavarrol@:~/super/sub1$ git status
# On branch development
nothing to commit, working directory clean
jmnavarrol@:~/super/sub1$ git log
commit 1f8273fc5b3c8402aab9a57008c70934692ccaa8
Author: jmnav <####>
Date:   Sat May 14 20:24:56 2016 +0200

    first commit into the sub1 repo
jmnavarrol@:~/super/sub1$
```

And what about **_SUPER_**?
```
jmnavarrol@:~/super/sub1$ cd ..
jmnavarrol@:~/super$ git log
commit 5677966145def72214491868a97324a0952e8041
Author: jmnav <####>
Date:   Sat May 14 20:22:20 2016 +0200

    first commit
jmnavarrol@:~/super$ git status
# On branch master
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#       sub1/
#
nothing added to commit but untracked files present (use "git add" to track)
jmnavarrol@:~/super$
```

Hummm... this looks like a problem... **_SUB1_** knows nothing about the parent repo (as it should) and **_SUPER_** sees **_SUB1_** as an untracked dir.  What we should do?  If we add the `sub1` directory to the **_SUPER_** repository, all kinds of nasty things will happen as the history of data within **_SUB1_** will be different depending if we ask to **_SUPER_** or **_SUB1_** (see, for instance, that **_SUPER_** _"thinks"_ to be in the _master_ branch, while **_SUB1_** sees itself in a different one).  On the other hand, if I just leave that `sub1` directory untracked, it not only will become cumbersome, but I risk adding it on **_SUPER_** by mistake.

Luckily, the `.gitignore` file comes to the rescue:
```
jmnavarrol@:~/super$ echo sub1/ >> .gitignore
jmnavarrol@:~/super$ git add .gitignore 
jmnavarrol@:~/super$ git commit -m "adding the subrepo to .gitignore so it goes away."
[master bca44d2] adding the subrepo to .gitignore so it goes away.
 1 file changed, 1 insertion(+)
 create mode 100644 .gitignore
jmnavarrol@:~/super$ git status
# On branch master
nothing to commit, working directory clean
jmnavarrol@:~/super$
```

See? **_SUB1_** has _"disappeared"_ from sight and it's guaranteed to stay that way (as long as the relevant entry within `.gitignore` stays in place).

From now on you can manage **_SUPER_** and **_SUB1_** just as two completely different repositories: no need to learn the arcanes of a new tool, no more _"Oh! I pushed to the wrong repo!"_, or _"I pulled from the parent repo... where the heck have my changes on the submodule gone!?"_, just plain old git commands.

<a name="going_forward"/>  
## going forward

There's no much forward to go to: the trick about `.gitignore` is basically all of it.  After all I promised _"The simplest way"_, right?

There is one problem, though, and it comes _because_ of the fact that **_SUPER_** and **_SUB1_** are so completely decoupled (which was my _selling point_ to start with): in the example above I worked on local repositories but what if, as it is the usual case, there is a whole team working out of remote repos?  When somebody clones **_SUPER_** he gets no hint on what to do to reach to **_SUB1_** or even that it exists at all.  Of course, one could resort to external documentation to tell him what to do but that wouldn't be _"making easy things easy"_ right?

For that I created a simple script, `build_subrepos.sh` that reads the subrepos to manage from a Bash Hash and recursively _git clones_ them.  By recursively I mean that it looks for other `build_subrepos.sh` scripts within the directory hierarchy to run them in turn so, starting from the top repo it clones all the defined subrepos in recursion.  Starting in any middle point, running it from **_SUB1_** in the scheme above, will do the expected: clone whatever repos there are defined down the line.  Once all the repos are in place, it's just a matter of using git as if they were completely in isolation.

I created projects at GitHub to publish the script and self-explain its working by means of the **_SUPER / SUB1 / SUB2 / SUBSUB_** example:
* The [**_SUB1_** repository](https://github.com/jmnavarrol/simplest-git-subrepos-sub1)
  * The [**_SUBSUB_** repository](https://github.com/jmnavarrol/simplest-git-subrepos-subsub)
* The [**_SUB2_** repository](https://github.com/jmnavarrol/simplest-git-subrepos-sub2)

----

<sub>**<a name="fn1">1</a>.[↩](#fe1)** See, for instance, this [Stack Overflow question](http://stackoverflow.com/questions/4500305/git-repository-within-git-repository).</sub>

<sub>**<a name="fn1">2</a>.[↩](#fe2)** Quite a lot of them, in fact.  Just to name a few:</sub>
* <sub>[git-subrepo](https://github.com/ingydotnet/git-subrepo)</sub>
* <sub>Google's [git-repo](https://code.google.com/p/git-repo/)</sub>
* <sub>[Gitslave](http://gitslave.sourceforge.net/)</sub>
* <sub>[Git External](http://danielcestari.com/git-external/)</sub>
* <sub>[clowder](https://raw.githubusercontent.com/JrGoodle/clowder/master/README.md) (by the way, it lists some other tools too)</sub>
* <sub>...you name it!</sub>
