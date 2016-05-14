# simplest-git-subrepos

The simplest way to manage git repos within git repos.

##### Table of Contents

* [the long explanation](#the_long_explanation)  
* [the use case](#the_use_case)

<a name="the_long_explanation"/>  
## the long explanation

It is [quite a common desire](https://www.google.es/search?q=git+repos+within+git+repos) to somehow have git repositories within git repositories<sup name="fe1">[[1]](#fn1)</sup>.  The usual answers involve convoluted incantations of [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) (with [the usual word of warning about their use](https://codingkilledthecat.wordpress.com/2012/04/28/why-your-company-shouldnt-use-git-submodules/)), [git-subtree](https://github.com/git/git/blob/master/contrib/subtree/git-subtree.txt) (which is [oh, so much easier!](https://developer.atlassian.com/blog/2015/05/the-power-of-git-subtree/?_ga=1.267682510.1986266707.1461346777)), or even especially crafted tools to deal with the complexity of those<sup name="fe1">[[2]](#fn2)</sup>.

In the end, the point is that something that sounds like it should be easy ends up being quite complex and -the worse of it, error prone.  But, does it need to be so complex?

The naive approach (_my_ naive approach at least) would be _...well, why not just dropping a git repo within another git repo?_  Much to my surprise after a long search on Google without results, that's not only perfectly possible, but trivially easy indeed, and basically without any bad side effect.

After such a _"discovery"_ I decided to share publicly by example in case others find it of benefit.

<a name="the_use_case"/>  
## the use case

It seems that the motto _"make easy things easy and hard things possible"_ can be tracked down to [Larry Wall](https://www.wikipedia.org/wiki/Larry_Wall) and his ["Learning Perl"](http://shop.oreilly.com/product/9781565922846.do), aka _the Llama book_.  I'm not telling submodules, subtrees, all those tools... are not without merit but I do say they fail Wall's saying: they certainly fail at making easy things easy.  But, what I want to suit then?

Let's have a project which I'll call **_SUPER_** which have some glue files in order to tie together another two ones which I'll call **_SUB1_** and **_SUB2_** (you can think of, say, a web front end using two modules, or whatever).  Just to make things funnier, let's imagine that **_SUB1_** also includes a deeper module, which I'll call **_SUBSUB_**.  Overall, the layout looks like this:

    [SUPER]|README.txt
           |
           |[SUB1]|file1
           |      |
           |      |[SUBSUB]|another_file
           |
           |[SUB2]|file2

Now, if I merely _consume_ the contents of **_SUB1_** and **_SUB2_** (and, of course, **_SUBSUB_**), using _vendor branches_ or just bringing them at build time from an artifacts repository will be surely good enough but, what if I want/need to also contribute to all of them?  Typically that's the case for corporate developments, where all those repositories belong to the same owner (the company) and the _"proper"_ way to test and evolution the submodules is by calling them from the parent one (or another similar one for testing purposes).  So, to recall the situation:
1. The functionallity of the submodules can only be ascertained (at least comfortably) by means of their integration with the SUPER one.
2. I have write access to at least some branches on the submodules.

## the solution

----

<sub>**<a name="fn1">1</a>.[↩](#fe1)** See, for instance, this [Stack Overflow question](http://stackoverflow.com/questions/4500305/git-repository-within-git-repository).</sub>

<sub>**<a name="fn1">2</a>.[↩](#fe2)** Quite a lot of them, in fact.  Just to name a few:</sub>
* <sub>[git-subrepo](https://github.com/ingydotnet/git-subrepo)</sub>
* <sub>Google's [git-repo](https://code.google.com/p/git-repo/)</sub>
* <sub>[Gitslave](http://gitslave.sourceforge.net/)</sub>
* <sub>[Git External](http://danielcestari.com/git-external/)</sub>
* <sub>...you name it!</sub>
