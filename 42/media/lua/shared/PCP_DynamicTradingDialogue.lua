--  ________________________________________________________________________
-- / Copyright (c) 2026 Phobos A. D'thorga                                \
-- |                                                                        |
-- |           /\_/\                                                         |
-- |         =/ o o \=    Phobos' PZ Modding                                |
-- |          (  V  )     All rights reserved.                              |
-- |     /\  / \   / \                                                      |
-- |    /  \/   '-'   \   This source code is part of the Phobos            |
-- |   /  /  \  ^  /\  \  mod suite for Project Zomboid (Build 42).         |
-- |  (__/    \_/ \/  \__)                                                  |
-- |     |   | |  | |     Unauthorised copying, modification, or            |
-- |     |___|_|  |_|     distribution of this file is prohibited.          |
-- |                                                                        |
-- \________________________________________________________________________/
--

---------------------------------------------------------------
-- PCP_DynamicTradingDialogue.lua
-- Registers chemistry-themed dialogue for the PCP "Chemist"
-- archetype in Dynamic Trading.
--
-- Uses DT's RegisterDialogue() API — no DT file edits needed.
-- All 6 dialogue types: Greetings, Buying, Selling, Sell_ask,
-- Idle, Request.
--
-- Only runs when DynamicTrading is loaded and has the
-- RegisterDialogue function available.
--
-- Part of PhobosChemistryPathways >= 0.19.1
---------------------------------------------------------------

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterDialogue then

    ---------------------------------------------------------------
    -- Greetings
    ---------------------------------------------------------------

    DynamicTrading.RegisterDialogue("Chemist", "Greetings", {
        EN = {
            Default = {
                "Just calibrating the pH meter. What do you need, {player.firstname}?",
                "Running a titration. You here for reagents or just browsing, {player}?",
                "The fume hood's on, so speak up. What can I get you, {player.firstname}?",
                "Another day, another distillation. What brings you to the lab, {player}?",
                "Got some fresh reagent stock today. What do you need, {player.firstname}?"
            },
            Morning = {
                "Morning shift in the lab. Best time for synthesis. What do you need, {player.firstname}?",
                "Early start. Reactions run cleaner in the cool air. What's the order, {player}?"
            },
            Evening = {
                "Wrapping up the evening batch. Quick trade, {player.firstname}?",
                "Evening, {player}. Hope you haven't been breathing anything funny."
            },
            Night = {
                "Running reactions by candlelight... not recommended. What do you need, {player.firstname}?",
                "Night chemistry is risky. Make it quick, {player}."
            },
            Raining = {
                "Rain's good for collecting distilled water. What brings you here, {player.firstname}?",
                "Humidity throws off my measurements. Keep it brief, {player}."
            },
            Fog = {
                "Can barely see the graduated cylinder in this fog. What's the word, {player.firstname}?",
                "Foggy conditions. Almost feels like a bad reaction in here, {player}."
            }
        }
    })

    ---------------------------------------------------------------
    -- Buying (player buys from Chemist)
    ---------------------------------------------------------------

    DynamicTrading.RegisterDialogue("Chemist", "Buying", {
        EN = {
            Generic = {
                "Quality reagent. The {item} is yours for {price}.",
                "Handle the {item} with care. That's {price}, {player.firstname}.",
                "I'll pull the {item} from storage. Proper grade, fair price.",
                "Tested and verified. The {item} is {price}."
            },
            HighValue = {
                "Lab-grade purity on that {item}. {price} is fair for what you're getting, {player.firstname}.",
                "Top-shelf reagent. This {item} doesn't come cheap at {price}, but it's worth it."
            },
            HighMarkup = {
                "Synthesis isn't cheap. {price} for the {item}. Purity costs.",
                "Reagent scarcity drives the price. {price} for the {item}. Take it or leave it."
            },
            LowMarkup = {
                "Overproduced this batch. {price} for the {item}.",
                "Clearing some shelf space. {item} for {price}. Good deal."
            },
            LastStock = {
                "That's the last of my {item}. Won't have more until the next synthesis run.",
                "Final unit. I'd hold onto it myself if I didn't need the trade."
            },
            SoldOut = {
                "Out of stock. Next batch needs time to react.",
                "Nothing left. Synthesis takes time, check back later."
            },
            NoCash = {
                "Insufficient funds, {player}. Even chemists need to eat. Need more than {price}.",
                "Can't do charity. Come back when you have the {price} for the {item}."
            }
        }
    })

    ---------------------------------------------------------------
    -- Selling (player sells to Chemist)
    ---------------------------------------------------------------

    DynamicTrading.RegisterDialogue("Chemist", "Selling", {
        EN = {
            Generic = {
                "I can always use more {item}. Here's {price}.",
                "Good supply. {price} for the {item}. I'll test purity later, {player.firstname}.",
                "I'll add the {item} to my stockpile. {price} sent."
            },
            HighValue = {
                "Excellent find. This {item} is research-grade. {price} well earned, {player.firstname}.",
                "Now that's a proper reagent. {price} for the {item}. Impressive sourcing."
            },
            HighMarkup = {
                "You drive a hard bargain, {player.firstname}. {price} for the {item}? Fine, I need it."
            },
            Trash = {
                "This {item} is barely above impure... but I can probably salvage it. {price}.",
                "Low grade, but a chemist makes do. {price} for the {item}."
            }
        }
    })

    ---------------------------------------------------------------
    -- Sell_ask (what the Chemist wants / refuses)
    ---------------------------------------------------------------

    DynamicTrading.RegisterDialogue("Chemist", "Sell_ask", {
        EN = {
            "Running low on {wants} for my next synthesis. Don't bother with {forbid}.",
            "I need {wants} to keep the lab running. Keep your {forbid}, no use for it here.",
            "Looking for {wants}. {forbid} just contaminates my workspace."
        }
    })

    ---------------------------------------------------------------
    -- Idle
    ---------------------------------------------------------------

    DynamicTrading.RegisterDialogue("Chemist", "Idle", {
        EN = {
            Generic = {
                "Measure twice, pour once. That's the rule in any lab.",
                "Always label your containers. Trust me on that one.",
                "The periodic table doesn't lie. People do, elements don't.",
                "Ventilation is half the battle with volatile compounds.",
                "Purity matters. A bad reagent ruins the whole batch."
            }
        }
    })

    ---------------------------------------------------------------
    -- Request
    ---------------------------------------------------------------

    DynamicTrading.RegisterDialogue("Chemist", "Request", {
        EN = {
            Generic = {
                "If you find any chemistry manuals out there, I'll pay well.",
                "I need more charcoal for filtration. Bring me some if you can.",
                "Sulphur's getting scarce. Any leads would be worth your while.",
                "Glass jars, bottles, anything that seals tight. A chemist can never have enough."
            }
        }
    })

    print("[PCP] DynamicTradingDialogue: Chemist dialogue registered")

end
