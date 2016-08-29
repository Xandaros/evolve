Introduction
============

First of all, I'd like to say a big thank you to Overv. He created evolve and supported it until the update to gmod 13 broke it completely.
He really did an incredible job to provide us this awesome mod and it is a honor to be allowed to continue it.

How do I install evolve?
========================

To install evolve, you can either download it as a zip or use git.

If you use git, simply clone it using `git clone --recursive https://github.com/Xandaros/evolve.git` and you're good to go.  
If you later want to update it, you can use `git pull` to update evolve and `git submodule update` to update the submodules, which are required to run evolve.

To install evolve with a zip file, first download the [evolve zip file](https://github.com/Xandaros/evolve/archive/master.zip) and unzip it into your addons folder. Make sure the folder in your addons directory contains a file called "README.md".  
Then, download the [vON zip file](https://github.com/vercas/vON/archive/master.zip) and unzip the "von.lua" it into addons/evolve/includes/ev_von. Make sure that the ev_von folder contains a file called "von.lua".

How do I become owner?
======================

If you're running a listen server, you're always owner. If you're running a dedicated server, join your server and type the following in the dedicated server console:
```
ev rank <your name> owner
```

How do I make people admin or super admin?
==========================================

Either...

Type in **chat**:
```
!rank playername admin/superadmin
```

Use the **menu**: Select player -> Administration -> Rank -> Admin/Super Admin

Use the **dedicated server console**:
```
ev rank <playername> admin/superadmin
```

The following ranks are available: guest, respected, admin, superadmin and owner.  
Note that people with the rank owner can only be demoted using the console and people can only be promoted to owner using the console. You can see the console as owner+ if you want.

How do I open the menu?
=======================

Just bind a key to +ev_menu. Note that this will likely change in the future, so keep watching this file!

Feature suggestions? Bugs found?
================================

https://github.com/Xandaros/evolve/issues


Credits
=======
Evolve is currently maintained by Melon Gaming (MGN)

The original author of evolve is Overv, with a lot of help of Divran

Evolve uses Vercas' Object Notation made by Vercas. (See: http://www.facepunch.com/showthread.php?t=1194008)

The playername boxes were originally made by ColtoM.

Troubleshooting
===============

Problem: Evolve not working at all.  
Solution: You most likely didn't install vON correctly. Make sure you have a file "von.lua" in `addons/evolve/lua/includes/ev_von/`. If not, see the installation tutorial above and read it carefully.
