// Workspace: Target workspace

//
// String added via add_build_string() from A:/Desarrollos/makis_ecs/build.jai:16.
//
DEBUG :: false;

//
// String added via add_build_string() from A:/Desarrollos/makis_ecs/build.jai:30.
//
#import "Math";
#import "Basic";

#insert #run init_recs();

Health   :: #type,distinct float32;

#insert #run init_components(Health);

EVENT_DEATH :: 1;
EVENT_DAMAGE :: 2;

on_entity_death :: (entity: Entity, data: *void) -> bool {
    print("Entity % died!\n", entity.index);
    return true;
}

on_entity_damaged :: (entity: Entity, data: *void) -> bool {
    print("Entity % took damage!\n", entity.index);
    return true;
}

main :: () {
    init_ecs();

    subscribe(EVENT_DEATH, on_entity_death);
    subscribe(EVENT_DAMAGE, on_entity_damaged);

    entity := create_entity();
    entity_add(entity, .Health);

    emit(EVENT_DAMAGE, entity);
    emit(EVENT_DEATH, entity);
}

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/.build/.added_strings_w3.jai:14.
//
MAX_ENTITIES   :: 1000;
MAX_COMPONENTS :: 30;
RECS_ASSERT    :: true;
#scope_file
#import "Basic";

init_ecs :: () {
    entities.count = MAX_ENTITIES;
    entities.data = entities_buffer.data;
    free_indices.count = 0;
    array_reserve(*free_indices, MAX_ENTITIES);
    entity_count = 0;
    for * entities_buffer it.generation = 0;
    init_groups();
    init_event_system();
}

#scope_export

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/src/mecs.jai:98.
//
sizes : [1]u32 : .[
	size_of(Health),
];

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/.build/.added_strings_w3.jai:18.
//
Component :: enum_flags u32 {
	Health;
}

_Health :: #run -> Health { x: Health; return x; };

entity_get :: inline (entity: Entity, $component: Health) -> Health {
	#if RECS_ASSERT assert(entity.index < MAX_ENTITIES);
	#if RECS_ASSERT assert(xx entities[entity.index].components & .Health, "entity doesnt have Health");
	return Health_Buff[entity.index];
}


type_get_component :: inline (_: Health) -> Component { return .Health; }
type_update_buffer :: inline (e: Entity, x: Health) {
	#if RECS_ASSERT assert(e.index < MAX_ENTITIES);
	Health_Buff[e.index] = x;
}

Health_Buff : [1000]Health = ---;
