Containerized Mediawiki
=======================

# I'm rebuilding the project right now. Branch 1_28 is going to be the most functional if you need a working wiki.

## Considerations for the current rebuild

First, things that need to be built - PHP and Parsoid in particular need a more central repository. I did pretty ok with it in the current implementation but multiple poorly maintained forks of official docker repos makes collaboration difficult. I like the way laradock does it, but I still will have to fork that because I need features it's not going to have like the syntax highlighting for code blocks. I could go look at the contribution guidelines, but I think I'm just going to poach their structure and adapt it to this project.

If you look at some of the other projects out there, they have env variables that allow you to programmatically launch your wiki. At the same time though many of these repos don't have binary isolation. They just lump stuff into a container. If that's the trade, it's one I don't want to make. I'm making this more for personal wiki's and internal small business. I'm not too worried about being able to deploy 20 of them.

I have some quality of life stuff that I do like auto placement of the localsettings file at wiki initialization. I gotta bail on that because it's not maintainable I don't think. But we'll see. I need some sort of like, patch applier that is code aware. I have what, 15-20 lines that inject into the mediawiki code. Provided nothing major changes I'd like to just keep injecting that, but I don't want it to break because someone added a single line of code. Then I need a bunch of tests etc etc. Maybe I'll look into something like travis so I don't have to maintain so much.

Mediawiki files, and composer deps. You would be surprised how not easy it is to grab the latest stable release of mediawiki. Their latest is a nightly build and since their github is a clone it doesn't support the "latest" api endpoint. Ultimately I need to decouple the project from mediawiki it's self. That just gets tricky, because of their development schemes. Parsoid does not play well with certain versions of mediawiki and the error messages are often esoteric, obfuscated, or non existent. As the project is now, a year later it all still works. It's pretty resistant to code rot because it's all pre built for the most part.
