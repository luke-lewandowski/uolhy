Ultima Online:LemiHelpYou
=====
A very simple script assistant for Ultima Online. It is written in LUA/OpenEasyUO.

What is it?
=====
Main purpose of UO:LHY is to create a new baseline for creating scripts. Instead of starting from the bottom each time you create new script, you use UO:LHY as a base line. 

It provides following features;

* Management UI controls life cycle. 
	* Each module is given a tab where UI controls can be placed. 
	* UO:LHY will automatically pick up all controls in all modules and destroy them when application is closing down.
* Configuration management
	* Configuration is kept in a global table where all modules can create new or edit existing configuration key value pairs.
	* Created per character/per shard and saved as JSON file.
	* It is broadcasted using `setatom`, therefore it is desired to create modules as separate threads (tabs) so that it doesn't affect other scripts.
* It relies heavily on UOExt which is a library of community created scripts
	* FluentUO - main library used for interacting with in-game objects.
* It is easy to create and add your own module.
	* UO:LHY comes with a "Looter" module. It is responsible for very simple logic around looting & skinning corpses. 

How is this project setup?
=====
UO:LHY has two branches.

* Main - used for stable (non bleeding edge) changes that should be stable.
* Dev - used for development. It contains latest bug fixes and enhancements.

You are welcome to either contribute to existing or fork and make it into completely something new. 

How to use UO:LHY?
=====
This is a small how to for users. No development skills necessary.

* Download source code for UO:LHY
	* Select either master or dev branch
	* Press on Download as ZIP button on the right hand side.
	* Create a folder inside `OpenEUO/Scripts/`. Call it uolhy.
	* Unzip content of the zip into that folder
* Open OpenEUO.exe
	* Load LHY.lua file and Start
	* Load LooterRun.lua file and Start.
* Browse around UO:LHY to make sure all settings are the way you want it
* Press Run button.

I would strongly recommend spending some time to see what options are available and customize them accordingly. (eg. list of items for looting)

*Note*: Always remember to save configuration once you are happy with your config. 

How is module structured?
=====

It is important to understand few concepts of how modules are created when writing one.

Each module has following parts.

- Set of configuration keys (things that you module needs to remember each time UO:LHY is started)
	* Configuration is a global table. All you need to do is to come up with a list of unique keys to use for your module so that you do not clash with other modules.
- Configuration interface - this simply holds all UI components for modyfing configuration keys.
	* UO:LHY will provide you with a table to use for all your UI components and set of very simple methods for creating/using them.
- Runner - this is your actual script that does something based on configuration set in interface.
	* This is a separate thread/script tab in openEUO. This is to make sure that your script doesn't affect other scripts.
