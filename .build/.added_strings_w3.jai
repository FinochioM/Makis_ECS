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

Player   :: #type,distinct void;
Position :: #type,distinct Vector2;
Velocity :: #type,distinct Vector2;
Health   :: #type,distinct float32;
Renderable :: #type,distinct void;

#insert #run init_components(Player, Position, Velocity, Health, Renderable);

Movement :: #run make_group(Position, Velocity);
PlayerMovement :: #run make_group(Position, Velocity, Player);
RenderableMovement :: #run make_group(Position, Renderable);

entities_processed := 0;
movement_count := 0;
player_movement_count := 0;
renderable_movement_count := 0;

count_system :: (e: Entity) { entities_processed += 1; }
count_movement :: (e: Entity) { movement_count += 1; }
count_player_movement :: (e: Entity) { player_movement_count += 1; }
count_renderable_movement :: (e: Entity) { renderable_movement_count += 1; }

test_groups :: () {
    init_ecs();

    // ########################################################################################
    print("Test 1: Basic group creation... ");
    register_group(Movement);
    e1 := create_entity(Movement);
    assert(entity_have(e1, .Position));
    assert(entity_have(e1, .Velocity));
    print("PASSED\n");

    // ########################################################################################
    print("Test 2: Group system iteration... ");
    entities_processed = 0;

    e2 := create_entity(Movement);
    e3 := create_entity();
    entity_add(e3, .Health);

    run_system(Movement, count_system);
    assert(entities_processed == 2, "Expected 2 entities to be processed, got %", entities_processed);
    print("PASSED\n");

    // ########################################################################################
    print("Test 3: Multiple groups... ");
    register_group(PlayerMovement);
    register_group(RenderableMovement);

    e4 := create_entity(PlayerMovement);
    assert(entity_have(e4, .Player));
    assert(entity_have(e4, .Position));
    assert(entity_have(e4, .Velocity));

    movement_count = 0;
    player_movement_count = 0;
    renderable_movement_count = 0;

    run_system(Movement, count_movement);
    run_system(PlayerMovement, count_player_movement);
    run_system(RenderableMovement, count_renderable_movement);

    assert(movement_count == 3, "Expected 3 movement entities, got %", movement_count);
    assert(player_movement_count == 1, "Expected 1 player movement entity, got %", player_movement_count);
    assert(renderable_movement_count == 0, "Expected 0 renderable movement entities, got %", renderable_movement_count);
    print("PASSED\n");

    // ########################################################################################

    print("Test 4: Component removal... ");
    old_components := entity_get(e1);
    print("Entity components before removal: %\n", old_components);

    entity_remove(e1, .Velocity);
    new_components := entity_get(e1);
    print("Entity components after removal: %\n", new_components);

    movement_count = 0;
    run_system(Movement, count_movement);
    assert(movement_count == 2, "Expected 2 movement entities after removal, got %", movement_count);
    print("PASSED\n");

    // ########################################################################################

    print("Test 5: Group membership updates... ");
    e5 := create_entity();
    entity_add(e5, .Position);
    entity_add(e5, .Velocity);
    entity_add(e5, .Renderable);

    movement_count = 0;
    renderable_movement_count = 0;

    run_system(Movement, count_movement);
    run_system(RenderableMovement, count_renderable_movement);

    assert(movement_count == 3);
    assert(renderable_movement_count == 1);
    print("PASSED\n");

    print("\nAll group tests passed successfully!\n");
}

main :: () {
    test_groups();
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
}

#scope_export

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/src/mecs.jai:119.
//
sizes : [5]u32 : .[
	size_of(Player),
	size_of(Position),
	size_of(Velocity),
	size_of(Health),
	size_of(Renderable),
];

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/.build/.added_strings_w3.jai:22.
//
Component :: enum_flags u32 {
	Player;
	Position;
	Velocity;
	Health;
	Renderable;
}

_Player :: Player;
_Position :: #run -> Position { x: Position; return x; };
_Velocity :: #run -> Velocity { x: Velocity; return x; };
_Health :: #run -> Health { x: Health; return x; };
_Renderable :: Renderable;

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
entity_get :: inline (entity: Entity, $component: Renderable) -> Renderable {
	#if RECS_ASSERT assert(entity.index < MAX_ENTITIES);
	#if RECS_ASSERT assert(xx entities[entity.index].components & .Renderable, "entity doesnt have Renderable");
	ret: Renderable;
	return ret;
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

type_get_component :: inline (_: Renderable) -> Component { return .Renderable; }
type_update_buffer :: inline (e: Entity, x: Renderable) {
	#if RECS_ASSERT assert(e.index < MAX_ENTITIES);
	Renderable_Buff[e.index] = x;
}

Position_Buff : [1000]Position = ---;
Velocity_Buff : [1000]Velocity = ---;
Health_Buff : [1000]Health = ---;

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/src/mecs.jai:335.
//
result |= .Position;
result |= .Velocity;

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/src/mecs.jai:335.
//
result |= .Position;
result |= .Velocity;
result |= .Player;

//
// #insert text. Generated from A:/Desarrollos/makis_ecs/src/mecs.jai:335.
//
result |= .Position;
result |= .Renderable;
