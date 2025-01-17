//Empty Sandbags
/obj/item/stack/emptysandbag
	name = "empty sandbag"
	desc = "A bag designed to be filled with sand."
	singular_name = "empty sandbag"
	icon_state = "sandbag_empty"
	w_class = ITEMSIZE_NORMAL
	force = 1
	throwforce = 1
	throw_speed = 5
	throw_range = 20
	drop_sound = 'sound/items/drop/backpack.ogg'
	pickup_sound = 'sound/items/pickup/backpack.ogg'
	matter = list("cloth" = 2)
	max_amount = 50
	attack_verb = list("tapped", "smacked", "flapped")

/obj/item/stack/emptysandbag/Initialize(mapload, new_amount, merge)
	. = ..()
	update_icon()

/obj/item/stack/emptysandbag/update_icon()
	var/amount = get_amount()
	if((amount >= 35))
		icon_state = "sandbag_empty_3"
	else if((amount < 35) && (amount > 1))
		icon_state = "sandbag_empty_2"
	else
		icon_state = "sandbag_empty"

/obj/item/stack/emptysandbag/attackby(var/obj/item/W, var/mob/user)
	if(istype(W, /obj/item/ore/glass) && !interact(user, src))
		if(do_after(user, 1 SECONDS, src) && use(1))
			var/turf/T = get_turf(user)
			to_chat(user, "<span class='notice'>You fill the sandbag.</span>")
			qdel(W)
			new /obj/item/stack/sandbags(T)
			return
	else if(is_sharp(W))
		user.visible_message("<span class='notice'>\The [user] begins cutting up [src] with [W].</span>", "<span class='notice'>You begin cutting up [src] with [W].</span>")
		if(do_after(user, 3 SECONDS, src) && use(1))
			to_chat(user, "<span class='notice'>You cut [src] into pieces!</span>")
			for(var/i in 1 to rand(1,2))
				new /obj/item/stack/material/cloth(drop_location())
		return
	return ..()

//Filled Sandbags
/obj/item/stack/sandbags
	name = "sandbag"
	desc = "This is a synthetic bag tightly packed with sand. It is designed to provide structural support and serve as a portable barrier."
	singular name = "sandbag"
	icon_state = "sandbags"
	w_class = ITEMSIZE_NORMAL
	force = 10
	throwforce = 15
	throw_speed = 3
	throw_range = 10
	drop_sound = 'sound/items/drop/backpack.ogg'
	pickup_sound = 'sound/items/pickup/backpack.ogg'
	matter = list("cloth" = 2)
	max_amount = 50
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/sandbags/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = sandbags_recipes
	update_icon()

/obj/item/stack/sandbags/update_icon()
	var/amount = get_amount()
	if((amount >= 35))
		icon_state = "sandbags_3"
	else if((amount < 35) && (amount > 1))
		icon_state = "sandbags_2"
	else
		icon_state = "sandbags"

var/global/list/datum/stack_recipe/sandbags_recipes = list( \
	new/datum/stack_recipe("sandbag barricade", /obj/structure/sandbag, 10, one_per_turf = 1, on_floor = 1))

/obj/item/stack/sandbags/attackby(var/obj/item/W, var/mob/user)
	if(is_sharp(W))
		user.visible_message("<span class='notice'>\The [user] begins cutting up [src] with [W].</span>", "<span class='notice'>You begin cutting up [src] with [W].</span>")
		if(do_after(user, 3 SECONDS, src) && use(1))
			to_chat(user, "<span class='notice'>You cut [src] into pieces, causing sand to spill everywhere!</span>")
			for(var/i in 1 to rand(1,1))
				new /obj/item/stack/material/cloth(drop_location())
				new /obj/item/ore/glass(drop_location())
		return
	else
		if(do_after(user, 1 SECONDS, src) && use(1))
			var/turf/T = get_turf(user)
			to_chat(user, "<span class='notice'>You cut the cords securing the sandbag, spilling sand everywhere!</span>")
			for(var/i in 1 to rand(1,1))
				new /obj/item/stack/emptysandbag(T)
				new /obj/item/ore/glass(T)
		return

//Sandbag Barricades

//To Add/Test:
//Table icon gen/checking.
//Climbing over a la table
var/list/sandbag_icon_cache = list()

/obj/structure/sandbag
	name = "sandbag barricade"
	desc = "A barrier made of stacked sandbags."
	icon = 'icons/obj/tables.dmi'
	icon_state = "sandbags"
	anchored = 1
	density = 1
	var/health = 100
	var/maxhealth = 100
	var/vestigial = TRUE

	connections = list("nw0", "ne0", "sw0", "se0")

/obj/structure/sandbag/Initialize(mapload, material_name)
	. = ..()
	health = maxhealth
	for(var/obj/structure/sandbag/S in loc)
		if(S != src)
			break_to_parts(full_return = 1)
			return
	if(mapload)
		return INITIALIZE_HINT_LATELOAD
	else
		//update_connections(TRUE)
		update_icon()

/obj/structure/sandbag/LateInitialize()
	. = ..()
	//update_connections(FALSE)
	update_icon()

/obj/structure/sandbag/Destroy()
	//update_connections(TRUE)
	. = ..()

/obj/structure/sandbag/examine(mob/user)
	. = ..()
	if(health < maxhealth)
		switch(health / maxhealth)
			if(0.0 to 0.5)
				. += "<span class='warning'>It looks severely damaged!</span>"
			if(0.25 to 0.5)
				. += "<span class='warning'>It looks damaged!</span>"
			if(0.5 to 1.0)
				. += "<span class='notice'>It has a few nicks and holes.</span>"


/obj/structure/sandbag/attackby(obj/item/W as obj, mob/user as mob)
	user.setClickCooldown(user.get_attack_speed(W))
	if(istype(W, /obj/item/stack/sandbags))
		var/obj/item/stack/sandbags/S = W
		if(health < maxhealth)
			if(S.get_amount() < 1)
				to_chat(user, "<span class='warning'>You need one sandbag to repair \the [src].</span>")
				return
			visible_message("<span class='notice'>[user] begins to repair \the [src].</span>")
			if(do_after(user,20) && health < maxhealth)
				if(S.use(1))
					health = maxhealth
					visible_message("<span class='notice'>[user] repairs \the [src].</span>")
				return
		return
	else
		switch(W.damtype)
			if("fire")
				health -= W.force * 1
			if("brute")
				health -= W.force * 0.75
		playsound(src, 'sound/weapons/smash.ogg', 50, 1)
		CheckHealth()
		..()

/obj/structure/sandbag/proc/CheckHealth()
	if(health <= 0)
		dismantle()
	return

/obj/structure/sandbag/take_damage(var/damage)
	health -= damage
	CheckHealth()
	return

/obj/structure/sandbag/attack_generic(var/mob/user, var/damage, var/attack_verb)
	visible_message("<span class='danger'>[user] [attack_verb] the [src]!</span>")
	playsound(src, 'sound/weapons/smash.ogg', 50, 1)
	user.do_attack_animation(src)
	health -= damage
	CheckHealth()
	return

/obj/structure/sandbag/proc/dismantle()
	visible_message("<span class='danger'>\The [src] falls apart!</span>")
	qdel(src)
	//Make it drop materials? I dunno. For now it just disappears.
	return

/obj/structure/sandbag/ex_act(severity)
	switch(severity)
		if(1.0)
			dismantle()
		if(2.0)
			health -= 25
			CheckHealth()

/obj/structure/sandbag/CanAllowThrough(atom/movable/mover, turf/target)//So bullets will fly over and stuff.
	. = ..()
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	return FALSE

/obj/structure/sandbag/proc/break_to_parts(full_return = 0)
	if(full_return || prob(20))
		new /obj/item/stack/sandbags(src.loc)
	else
		new /obj/item/stack/material/cloth(src.loc)
		new /obj/item/ore/glass(src.loc)
	qdel(src)
	return


//All this table icon code is gibberish to me.
/*
/proc/get_sandbag_image(var/icon/sicon,var/siconstate,var/sdir)
	var/icon_cache_key = "\ref[sicon]-[siconstate]-[sdir]"
	var/image/I = sandbag_icon_cache[icon_cache_key]
	if(!I)
		I = image(icon = sicon, icon_state = siconstate, dir = sdir)
		sandbag_icon_cache[icon_cache_key] = I

	return I

/obj/structure/sandbag/update_icon()
	if(vestigial)
		icon_state = "sandbags"
		overlays.Cut()

		for(var/i = 1 to 4)
			var/image/I = get_sandbag_image(icon, "sandbags_[connections[i]]", 1<<(i-1))
			overlays += I

		overlays.Cut()
		var/type = 0
		var/sandbagdirs = 0
		for(var/direction in list(turn(dir,90), turn(dir,-90)) )
			var/obj/structure/sandbag/S = locate(/obj/structure/sandbag ,get_step(src,direction))
			if (S && S.dir == src.dir)
				type++
				sandbagdirs |= direction

		type = "[type]"
		if (type=="1")
			if (sandbagdirs & turn(dir,90))
				type += "-"
			if (sandbagdirs & turn(dir,-90))
				type += "+"

// set propagate if you're updating a table that should update tables around it too, for example if it's a new table or something important has changed (like material).
/obj/structure/sandbag/proc/update_connections(propagate=0)
	if(!vestigial)
		connections = list("0", "0", "0", "0")
		if(propagate)
			for(var/obj/structure/sandbag/S in orange(src, 1))
				S.update_connections()
				S.update_icon()
			return

	var/list/blocked_dirs = list()
	for(var/obj/structure/window/W in get_turf(src))
		if(W.is_fulltile())
			connections = list("0", "0", "0", "0")
			return
		blocked_dirs |= W.dir

	for(var/D in list(NORTH, SOUTH, EAST, WEST) - blocked_dirs)
		var/turf/T = get_step(src, D)
		for(var/obj/structure/window/W in T)
			if(W.is_fulltile() || W.dir == GLOB.reverse_dir[D])
				blocked_dirs |= D
				break
			else
				if(W.dir != D) // it's off to the side
					blocked_dirs |= W.dir|D // blocks the diagonal

	for(var/D in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST) - blocked_dirs)
		var/turf/T = get_step(src, D)

		for(var/obj/structure/window/W in T)
			if(W.is_fulltile() || W.dir & GLOB.reverse_dir[D])
				blocked_dirs |= D
				break

	// Blocked cardinals block the adjacent diagonals too. Prevents weirdness with tables.
	for(var/x in list(NORTH, SOUTH))
		for(var/y in list(EAST, WEST))
			if((x in blocked_dirs) || (y in blocked_dirs))
				blocked_dirs |= x|y

	var/list/connection_dirs = list()

	for(var/obj/structure/sandbag/S in orange(src, 1))
		var/S_dir = get_dir(src, S)
		if(S_dir in blocked_dirs)
			continue
		if(propagate)
			spawn(0)
				S.update_connections()
				S.update_icon()

	connections = dirs_to_corner_states(connection_dirs)
*/
