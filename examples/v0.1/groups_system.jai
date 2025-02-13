// V_0.1 - 13/02/2025.
// Test for the feature of "Component Grouping System".
/*
###############################################################################

This file demonstrates the Component Grouping System functionality through 5 tests:

Test 1 - Basic Group Creation
    Shows how to create a group (Movement = Position + Velocity) and verify that
    entities created with this group get all required components automatically.

Test 2 - Group System Iteration
    Verifies that systems only process entities that have all group components.
    Creates 3 entities: 2 with Movement group, 1 with only Health.
    Confirms system only processes the 2 Movement entities.

Test 3 - Multiple Groups
    Tests handling multiple groups simultaneously (Movement, PlayerMovement, RenderableMovement).
    Verifies correct entity counts across different group systems.

Test 4 - Component Removal
    Tests dynamic group membership by removing a component (Velocity).
    Shows that entity leaves Movement group when it loses required components.

Test 5 - Dynamic Group Membership
    Shows that entities join groups automatically when they gain the right
    component combination, even when components are added individually.

Expected Output:

Test 1: Basic group creation... PASSED
Test 2: Group system iteration... PASSED
Test 3: Multiple groups... PASSED
Test 4: Component removal... Entity components before removal: Position | Velocity
Entity components after removal: Position
PASSED
Test 5: Group membership updates... PASSED
###############################################################################

*/

#import "Math";
#import "Basic";

@init_recs();

Player   :: @comp void;
Position :: @comp Vector2;
Velocity :: @comp Vector2;
Health   :: @comp float32;
Renderable :: @comp void;

@init_components(Player, Position, Velocity, Health, Renderable);

Movement :: @group(Position, Velocity);
PlayerMovement :: @group(Position, Velocity, Player);
RenderableMovement :: @group(Position, Renderable);

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