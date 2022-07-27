GLOBAL_LIST_INIT(potion_rates, list(
	/obj/item/slimepotion/slime/sentience		=9,
	/obj/item/slimepotion/speed		=2,
	/obj/item/slimepotion/slime/renaming			=9,
	/obj/item/slimepotion/slime/slimeradio		=9,
	/obj/item/slimepotion/peacepotion		=9
))

GLOBAL_LIST_INIT(gunparts_rates, list(
	/obj/item/stack/sheet/metal/ten,
	/obj/item/stack/sheet/metal/five,
	/obj/item/stack/sheet/plasteel/five,
	/obj/item/stack/sheet/plastic/five,
	/obj/item/stack/crafting/metalparts/five,
	/obj/item/stack/crafting/goodparts/three
))

/obj/structure/sacrificealtar
	name = "sacrificial altar"
	desc = "An altar designed to perform blood sacrifice for a deity."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	anchored = TRUE
	density = FALSE
	can_buckle = 1
	max_integrity = 30000
	var/divine_chance = 5

/obj/structure/sacrificealtar/attackby(obj/item/I, mob/user)
	. = ..()
	var/divine = prob(divine_chance)
	if(.)
		return
	if(istype(I, /obj/item/gun))
		to_chat(user, "<span class='notice'>You attempt to sacrifice [I] by invoking the sacrificial ritual, it melts and breaks into pieces.</span>")
		qdel(I)
		message_admins("[ADMIN_LOOKUPFLW(user)] has sacrificed [key_name_admin(I)] on the sacrificial altar at [AREACOORD(src)].")
		switch(divine)
			if(FALSE)
				var/loot_item = pick(GLOB.gunparts_rates)
				new loot_item (get_turf(user))
				return
			if(TRUE)
				var/pick_adcomp = pickweight(GLOB.loot_craft_advanced)
				new pick_adcomp(get_turf(user))
				return
	if(!has_buckled_mobs())
		return
	var/mob/living/L = locate() in buckled_mobs
	if(!L)
		return
	if(istype(I, /obj/item/clothing/accessory/talisman))
		to_chat(user, "<span class='notice'>You attempt to sacrifice [L] by invoking the sacrificial ritual, during the sacrifice, you removed something from the stomach of the victim.</span>")
		L.gib()
		message_admins("[ADMIN_LOOKUPFLW(user)] has sacrificed [key_name_admin(L)] on the sacrificial altar at [AREACOORD(src)].")
		switch(divine)
			if(FALSE)
				var/seed_item = pick(GLOB.loot_seed)
				new seed_item (get_turf(user))
				return
			if(TRUE)
				var/pick_potion = pickweight(GLOB.potion_rates)
				new pick_potion(get_turf(user))
				return
	else
		return

/obj/structure/healingfountain
	name = "healing fountain"
	desc = "A fountain containing the waters of life."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "fountain"
	anchored = TRUE
	density = TRUE
	var/time_between_uses = 1800
	var/last_process = 0

/obj/structure/healingfountain/on_attack_hand(mob/living/user, act_intent = user.a_intent, unarmed_attack_flags)
	. = ..()
	if(.)
		return
	if(last_process + time_between_uses > world.time)
		to_chat(user, "<span class='notice'>The fountain appears to be empty.</span>")
		return
	last_process = world.time
	to_chat(user, "<span class='notice'>The water feels warm and soothing as you touch it. The fountain immediately dries up shortly afterwards.</span>")
	user.reagents.add_reagent(/datum/reagent/medicine/omnizine/godblood,20)
	update_icon()
	addtimer(CALLBACK(src, /atom/.proc/update_icon), time_between_uses)

/obj/structure/healingfountain/update_icon_state()
	if(last_process + time_between_uses > world.time)
		icon_state = "fountain"
	else
		icon_state = "fountain-red"
