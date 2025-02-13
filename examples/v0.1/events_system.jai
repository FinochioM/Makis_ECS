// V_0.1 - 13/02/2025.
// Test for the feature of "Event System".
/*
###############################################################################

This file demonstrates the Event System's core functionality, showing how
components can communicate and react to state changes without direct coupling.

Key Features Demonstrated:
1. Event Registration
   - Shows how systems can subscribe to specific events
   - Demonstrates callback registration with event IDs

2. Event Emission
   - Shows how to trigger events for specific entities
   - Demonstrates the event propagation system

3. Event Handling
   - Shows how callbacks process entity-specific events
   - Demonstrates the boolean return for handling confirmation

Event Types:
EVENT_DEATH  (ID: 1) - Triggered when an entity should be destroyed
EVENT_DAMAGE (ID: 2) - Triggered when an entity takes damage

Expected Output:
Entity 0 took damage!
Entity 0 died!

###############################################################################
*/


#import "Math";
#import "Basic";

@init_recs();

Health   :: @comp float32;

@init_components(Health);

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