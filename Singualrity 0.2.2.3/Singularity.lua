SMODS.Atlas {
	-- Key for code to find it with
	key = "singularityatlas",
	-- The name of the file, for the code to pull the atlas from
	path = "Singularity.png",
	-- Width of each sprite in 1x size
	px = 70,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Sound {
    key = 'LSingle_SingularityUpgrade',
    path = 'Bwah.ogg',
}

SMODS.Joker {
    key = 'singular',
    loc_txt = {
        name = 'Singularity',
        text = {
            "{C:mult}+#1# {} Mult.",
            "For every {C:attention}High Card{} hand played,",
            "Mult gained is multiplied by 3."
        }
    },
    config = { extra = { mult = 1, mult_gain = 3 } },
    rarity = 4, -- Legendary
    atlas = 'singularityatlas',
    pos = { x = 0, y = 0 },
    cost = 16,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult, card.ability.extra.mult_gain } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult_mod = card.ability.extra.mult,
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
            }
        end

        if context.before and context.scoring_name == "High Card" and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult * card.ability.extra.mult_gain
            return {
                message = 'Upgraded!',
                sound = 'LSingle_SingularityUpgrade',
                colour = G.C.MULT,
                card = card
            }
        end
    end
}


SMODS.Atlas {
	-- Key for code to find it with
	key = "collapseatlas",
	-- The name of the file, for the code to pull the atlas from
	path = "Collapse.png",
	-- Width of each sprite in 1x size
	px = 70,
	-- Height of each sprite in 1x size
	py = 95
}

SMODS.Sound {
    key = 'LSingle_StellarTransform',
    path = 'CollapseBoom.ogg', 
}
SMODS.Sound {
    key = 'LSingle_StellarUpgrade',
    path = 'Collapsing.ogg',
}

SMODS.Joker {
    key = 'stellar_collapse',
    loc_txt = {
        name = 'Stellar Collapse',
        text = {
            "After {C:attention}#2# High Card{} hands,",
            "collapses into {C:legendary}Singularity{}.",
            "{C:inactive}(Currently {C:attention}#1#{C:inactive} played)",
        }
    },
    config = { extra = { high_card_count = 0, high_card_limit = 20 } },
    rarity = 2,
    atlas = 'collapseatlas',
    pos = { x = 0, y = 0 },
    cost = 6,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.high_card_count, card.ability.extra.high_card_limit } }
    end,

    calculate = function(self, card, context)
        if context.before and context.scoring_name == "High Card" and not context.blueprint then
            -- Increment count
            card.ability.extra.high_card_count = card.ability.extra.high_card_count + 1

            -- Check if it should transform
            if card.ability.extra.high_card_count >= card.ability.extra.high_card_limit then
                play_sound('LSingle_StellarTransform', 0.7, 1.3)
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.15,
                    func = function()
                        card:set_ability("j_LSingle_singular")
                        card:juice_up(0.3, 0.3)
                        return true
                    end,
                }))
            end

            -- Normal progress message
            if card.ability.extra.high_card_count < card.ability.extra.high_card_limit then
                return {
                    message = "Collapsing...",
                    sound = 'LSingle_StellarUpgrade',
                    colour = G.C.ATTENTION,
                    card = card
                }
            end
        end
    end
}