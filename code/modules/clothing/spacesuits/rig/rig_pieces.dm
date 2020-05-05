/*
 * Defines the helmets, gloves and shoes for rigs.
 */

/obj/item/clothing/head/helmet/space/rig
	name = "helmet"
	flags = PHORONGUARD
	item_flags = THICKMATERIAL|ALLOW_SURVIVALFOOD
	flags_inv = 		 HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	body_parts_covered = HEAD|FACE|EYES
	heat_protection =    HEAD|FACE|EYES
	cold_protection =    HEAD|FACE|EYES
	brightness_on = 4
	sprite_sheets = list(
		SPECIES_TAJ = 'icons/mob/species/tajaran/helmet.dmi',
		SPECIES_SKRELL = 'icons/mob/species/skrell/helmet.dmi',
		SPECIES_UNATHI = 'icons/mob/species/unathi/helmet.dmi',
		SPECIES_VOX = 'icons/mob/species/vox/head.dmi',
		SPECIES_TESHARI = 'icons/mob/species/seromi/head.dmi'
		)
	species_restricted = null
	max_pressure_protection = null
	min_pressure_protection = null
	force = 3 // if you're headbutting someone with something meant to protect you from space...

/obj/item/clothing/gloves/gauntlets/rig
	name = "gauntlets"
	item_flags = THICKMATERIAL
	flags = PHORONGUARD
	body_parts_covered = HANDS
	heat_protection =    HANDS
	cold_protection =    HANDS
	species_restricted = null
	gender = PLURAL

/obj/item/clothing/shoes/magboots/rig
	name = "boots"
	flags = PHORONGUARD
	body_parts_covered = FEET
	cold_protection = FEET
	heat_protection = FEET
	species_restricted = null
	gender = PLURAL
	icon_base = null
	force = 5 // if you're kicking someone with something meant to keep you locked on a hunk of metal...

/obj/item/clothing/suit/space/rig
	name = "chestpiece"
	flags = PHORONGUARD
	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/suit_cooling_unit)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection =	 UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection =	 UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv =			 HIDEJUMPSUIT|HIDETAIL
	item_flags =		 THICKMATERIAL | AIRTIGHT
	slowdown = 0
	//will reach 10 breach damage after 25 laser carbine blasts, 3 revolver hits, or ~1 PTR hit. Completely immune to smg or sts hits.
	breach_threshold = 38
	resilience = 0.2
	can_breach = 1
	sprite_sheets = list(
		SPECIES_TAJ = 'icons/mob/species/tajaran/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/species/unathi/suit.dmi',
		SPECIES_VOX = 'icons/mob/species/vox/suit.dmi',
		SPECIES_TESHARI = 'icons/mob/species/seromi/suit.dmi'
		)
	supporting_limbs = list()
	var/obj/item/material/knife/tacknife
	max_pressure_protection = null
	min_pressure_protection = null

/obj/item/clothing/suit/space/rig/attack_hand(var/mob/living/M)
	if(tacknife)
		tacknife.loc = get_turf(src)
		if(M.put_in_active_hand(tacknife))
			to_chat(M, "<span class='notice'>You slide \the [tacknife] out of [src].</span>")
			playsound(M, 'sound/weapons/flipblade.ogg', 40, 1)
			tacknife = null
			update_icon()
		return
	..()

/obj/item/clothing/suit/space/rig/attackby(var/obj/item/I, var/mob/living/M)
	if(istype(I, /obj/item/material/knife/tacknife))
		if(tacknife)
			return
		M.drop_item()
		tacknife = I
		I.loc = src
		to_chat(M, "<span class='notice'>You slide the [I] into [src].</span>")
		playsound(M, 'sound/weapons/flipblade.ogg', 40, 1)
		update_icon()
	..()

//TODO: move this to modules
/obj/item/clothing/head/helmet/space/rig/proc/prevent_track()
	return 0

/obj/item/clothing/gloves/gauntlets/rig/Touch(var/atom/A, var/proximity)

	if(!A || !proximity)
		return 0

	var/mob/living/carbon/human/H = loc
	if(!istype(H) || (!H.back && !H.belt))
		return 0

	var/obj/item/rig/suit = H.back
	if(!suit || !istype(suit) || !suit.installed_modules.len)
		return 0

	for(var/obj/item/rig_module/module in suit.installed_modules)
		if(module.active && module.activates_on_touch)
			if(module.engage(A))
				return 1

	return 0

//Rig pieces for non-spacesuit based rigs

/obj/item/clothing/head/lightrig
	name = "mask"
	body_parts_covered = HEAD|FACE|EYES
	heat_protection =    HEAD|FACE|EYES
	cold_protection =    HEAD|FACE|EYES
	flags =              THICKMATERIAL|AIRTIGHT|PHORONGUARD

/obj/item/clothing/suit/lightrig
	name = "suit"
	allowed = list(/obj/item/flashlight)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection =    UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv =          HIDEJUMPSUIT
	flags =              THICKMATERIAL|PHORONGUARD

/obj/item/clothing/shoes/lightrig
	name = "boots"
	body_parts_covered = FEET
	cold_protection = FEET
	heat_protection = FEET
	flags = PHORONGUARD
	species_restricted = null
	gender = PLURAL

/obj/item/clothing/gloves/gauntlets/lightrig
	name = "gloves"
	flags = THICKMATERIAL
	body_parts_covered = HANDS
	heat_protection =    HANDS
	cold_protection =    HANDS
	flags = PHORONGUARD
	species_restricted = null
	gender = PLURAL
