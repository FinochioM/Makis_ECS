// Workspace: Target workspace

//
// String added via add_build_string() from A:/Desarrollos/makis_ecs/build.jai:16.
//
DEBUG :: false;

//
// String added via add_build_string() from A:/Desarrollos/makis_ecs/build.jai:30.
//
#import "Math";

#insert #run init_recs();

Print    :: #type,distinct void;
Position :: #type,distinct Vector2;
Velocity :: #type,distinct Vector2;

#insert #run init_components(Print, Position, Velocity);

printing_system :: inline (e: Entity) {
    pos := entity_get(e, _Position);
    print("%\n", pos);
}

movement_system :: inline (e: Entity) {
    pos := entity_get(e, _Position);
    vel := entity_get(e, _Velocity);
    pos.x += vel.x;
    pos.y += vel.y;
    entity_update(e, pos);
}

main :: () {
    init_ecs();
    e := create_entity();

    entity_add(e, Position.{});
    entity_add(e, Velocity.{1, 0});
    entity_add(e, .Print);

    e = create_entity();

    entity_add(e, Position.{});
    entity_add(e, Velocity.{0, 1});
    entity_add(e, .Print);

    e = create_entity();

    entity_add(e, Position.{});
    entity_add(e, .Print);

    for 0..3 {
        print("frame %:\n", it);
        run_system(.Position | .Velocity, movement_system);
        run_system(.Position | .Print, printing_system);
        print("\n");
    }

    for iter_entities(.Position) {
        entity_update(it, Position.{});
    }
}

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/.build/.added_strings_w3.jai:13.
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
}

#scope_export

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/src/mecs.jai:119.
//
sizes : [3]u32 : .[
	size_of(Print),
	size_of(Position),
	size_of(Velocity),
];

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/.build/.added_strings_w3.jai:19.
//
Component :: enum_flags u32 {
	Print;
	Position;
	Velocity;
}

_Print :: Print;
_Position :: #run -> Position { x: Position; return x; };
_Velocity :: #run -> Velocity { x: Velocity; return x; };

entity_get :: inline (entity: Entity, $component: Print) -> Print {
	#if RECS_ASSERT assert(entity.index < MAX_ENTITIES);
	#if RECS_ASSERT assert(xx entities[entity.index].components & .Print, "entity doesnt have Print");
	ret: Print;
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


type_get_component :: inline (_: Print) -> Component { return .Print; }
type_update_buffer :: inline (e: Entity, x: Print) {
	#if RECS_ASSERT assert(e.index < MAX_ENTITIES);
	Print_Buff[e.index] = x;
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

Position_Buff : [1000]Position = ---;
Velocity_Buff : [1000]Velocity = ---;
