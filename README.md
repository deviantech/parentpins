# ParentPins

ParentPins.com was a fully-featured, parent-centric pinterest clone built from scratch.  It shut its doors in 2014, but code is saved here for posterity (development screenshot below).

![Screenshot](public/screens/demo.png?raw=true)


The javascript necessary to create and manage the Pin It! bookmarklet was of particular interest.



###### Requirements:
* Ruby 2.0.0
* Mysql 5.0.3+ (pins.description longer than 255)

###### Dev Workarounds:
* If jquery-ujs appears included twice in development (e.g. data-confirm actions are being called twice), clear out public/assets/*
