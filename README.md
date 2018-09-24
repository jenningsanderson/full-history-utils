# OSM Historical Planet Utilities

Working with the historical planet files and osmium export isn't trivial, but it shouldn't be that hard either.

This is a collection of bounding boxes and configuration settings for working with OSM history files and the `osmium-tool` to to get wrangle historical OSM data from the full planet PBF.

Available commands: 

	download	Download the latest history file to this directory.
	extract-cities	Extract all of the cities located in the bboxes directory out of the history file.
	extract-countries	Extract all of the cities in the bboxes directory
	extract <name>	Extract the bbox file located in the bboxes directory.

Also available here are various osmium-extract configuration files for a variety of analysis needs.
