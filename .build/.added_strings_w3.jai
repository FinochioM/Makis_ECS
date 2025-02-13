// Workspace: Target workspace

//
// String added via add_build_string() from A:/Desarrollos/makis_ecs/build.jai:16.
//
DEBUG :: false;

//
// String added via add_build_string() from A:/Desarrollos/makis_ecs/build.jai:29.
//
#import "Math";
#import "Basic";

#insert #run init_recs();

// init comps
Player   :: #type,distinct void;
Position :: #type,distinct Vector2;
Velocity :: #type,distinct Vector2;
Health   :: #type,distinct float32;

#insert #run init_components(Player, Position, Velocity, Health);

// start da big
main :: () {
    init_ecs();

    print("Creating first entity...\n");
    e1 := create_entity();
    print("First entity - Index: %, Generation: %\n", e1.index, e1.generation);

    entity_add(e1, Position.{10, 20});

    old_index := e1.index;
    old_generation := e1.generation;

    print("Removing Entity...\n");
    remove_entity(e1);

    print("Creating second entity...\n");
    e2 := create_entity();
    print("Second entity - Index: %, Generation: %\n", e2.index, e2.generation);

    print("Recycling verification:\n");
    print("SAME INDEX? %\n", e2.index == old_index);
    print("DIFFERENT GENERATION? %\n", e2.generation != old_generation);

    print("\nTrying to use old entity reference:\n");

    if entity_have(e1, .Position) {
        print("ERROR: Should not reach this code!\n");
    } else {
        print("Correctly detected invalid entity!\n");
    }
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
}

#scope_export

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/src/recs.jai:74.
//
sizes : [4]u32 : .[
	size_of(Player),
	size_of(Position),
	size_of(Velocity),
	size_of(Health),
];

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/.build/.added_strings_w3.jai:22.
//
Component :: enum_flags u32 {
	Player;
	Position;
	Velocity;
	Health;
}

_Player :: Player;
_Position :: #run -> Position { x: Position; return x; };
_Velocity :: #run -> Velocity { x: Velocity; return x; };
_Health :: #run -> Health { x: Health; return x; };

entity_get :: inline (entity: Entity, $component: Player) -> Player {
	#if RECS_ASSERT assert(entity.index < MAX_ENTITIES);
	#if RECS_ASSERT assert(xx entities[entity.index].components & .Player, "entity doesnt have Player");
	ret: Player;
	return ret;
}
entity_get :: inline (entity: Entity, $component: Position) -> Position {
	#if RECS_ASSERT assert(entity.index < MAX_ENTITIES);
	#if RECS_ASSERT assert(xx entities[entity.index].components & .Position, "entity doesnt have Position");
	return Position_Buff[entity.index];
}
entity_get :: inline (entity: Entity, $component: Velocity) -> Velocity {
	#if RECS_ASSERT assert(entity.index < MAX_ENTITIES);
	#if RECS_ASSERT assert(xx entities[entity.index].components & .Velocity, "entity doesnt have Velocity");
	return Velocity_Buff[entity.index];
}
entity_get :: inline (entity: Entity, $component: Health) -> Health {
	#if RECS_ASSERT assert(entity.index < MAX_ENTITIES);
	#if RECS_ASSERT assert(xx entities[entity.index].components & .Health, "entity doesnt have Health");
	return Health_Buff[entity.index];
}


type_get_component :: inline (_: Player) -> Component { return .Player; }
type_update_buffer :: inline (e: Entity, x: Player) {
	#if RECS_ASSERT assert(e.index < MAX_ENTITIES);
	Player_Buff[e.index] = x;
}

type_get_component :: inline (_: Position) -> Component { return .Position; }
type_update_buffer :: inline (e: Entity, x: Position) {
	#if RECS_ASSERT assert(e.index < MAX_ENTITIES);
	Position_Buff[e.index] = x;
}

type_get_component :: inline (_: Velocity) -> Component { return .Velocity; }
type_update_buffer :: inline (e: Entity, x: Velocity) {
	#if RECS_ASSERT assert(e.index < MAX_ENTITIES);
	Velocity_Buff[e.index] = x;
}

type_get_component :: inline (_: Health) -> Component { return .Health; }
type_update_buffer :: inline (e: Entity, x: Health) {
	#if RECS_ASSERT assert(e.index < MAX_ENTITIES);
	Health_Buff[e.index] = x;
}

Position_Buff : [1000]Position = ---;
Velocity_Buff : [1000]Velocity = ---;
Health_Buff : [1000]Health = ---;
