
# Current Features:

 

 

    Computes and reports what your stagger level should be, if your current damage intake remains stable. Your actual stagger level will of course almost never be at this level, but will constantly be moving towards this value. 

 

    "Why is this good information to know?", you ask. Well, it's simple - when your actual level of stagger is below this value (which I call Normalized Stagger), it will tend to increase, since you are putting more damage into stagger than is bleeding out. Conversely, when your actual stagger level is greater than Normalized Stagger, then it will tend to decrease over time. In other words, comparing your Normalized Stagger to true Stagger gives you an idea of exactly how much of an asset (or liability!) stagger is at that moment.

 

# Planned Features

 

    Standalone graphical display - currently, there's no visual component to this, and requires external code (such as a weakaura) to extract the information. I wanted to release this without a graphical display primarily because a large user base already uses this weakaura of mine, which utilizes the same underlying code. By switching to an addon format for at least the backend of that aura, updates should be much simpler and hassle-free.

 

    Healer-related features - Along with converting this weakaura into addon format as well (as an additional function alongside Normalized Stagger), I plan to add the ability to parse what actions your healers are taking, and judge whether or not they are spending an excess amount of time or mana on handling your stagger (and consequently whether purifying would ease their burden significantly). After all, you don't need to be perfectly self sufficient as a tank; you only need to be a minimal burden on your healers!
