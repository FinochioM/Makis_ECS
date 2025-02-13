// V_0.1 - 13/02/2025.
// Test for the feature of "Component Interaction and Event System".
/*
###############################################################################

This file demonstrates a practical implementation of the ECS event system using
a health and damage-over-time (DoT) system as an example. It shows how components
can interact with each other and how events can be used to handle state changes.

Key Features Demonstrated:

1. Structured Components
   - Health component with current and maximum values
   - DamageOverTime component with damage rate and duration
   - Shows how to properly structure numeric components

2. Component Interaction
   - Health component being modified by damage and healing functions
   - DamageOverTime component affecting Health over multiple ticks
   - Demonstrates proper component access using _ComponentName syntax

3. Event System Integration
   - Death event triggered when health reaches 0
   - Event subscription and handling
   - Shows how systems can react to component state changes

4. Utility Functions
   - apply_damage: Handles damage application and death check
   - heal: Handles health restoration with max cap
   - process_dot: Manages DoT effect over time

Expected Output:
Initial health: 100
Health after 30 damage: 70
Health after healing 20: 90

Tick 1:
Health after DoT tick: 80

Tick 2:
Health after DoT tick: 70

Tick 3:
Health after DoT tick: 60

###############################################################################
*/

#import "Math";
#import "Basic";

@init_recs();

Health :: @comp struct {
    value: float32;
    max_value: float32;
};

DamageOverTime :: @comp struct {
    damage_per_tick: float32;
    ticks_remaining: int;
};

@init_components(Health, DamageOverTime);

EVENT_DEATH :: 1;

on_entity_death :: (entity: Entity, data: *void) -> bool {
    print("Entity % has died!\n", entity.index);
    return true;
}

apply_damage :: (entity: Entity, amount: float32) {
    health := entity_get(entity, _Health);
    health.value = max(cast(float32)0, health.value - amount);
    entity_update(entity, health);

    if health.value <= 0 emit(EVENT_DEATH, entity);
}

heal :: (entity: Entity, amount: float32) {
    health := entity_get(entity, _Health);
    health.value = min(health.max_value, health.value + amount);
    entity_update(entity, health);
}

process_dot :: (entity: Entity) {
    dot := entity_get(entity, _DamageOverTime);
    if dot.ticks_remaining > 0 {
        apply_damage(entity, dot.damage_per_tick);
        dot.ticks_remaining -= 1;
        entity_update(entity, dot);

        if dot.ticks_remaining <= 0 {
            entity_remove(entity, _DamageOverTime);
        }
    }
}

main :: () {
    init_ecs();

    subscribe(EVENT_DEATH, on_entity_death);

    character := create_entity();
    entity_add(character, Health.{100, 100});

    print("Initial health: %\n", entity_get(character, _Health).value);

    apply_damage(character, 30);
    print("Health after 30 damage: %\n", entity_get(character, _Health).value);

    heal(character, 20);
    print("Health after healing 20: %\n", entity_get(character, _Health).value);

    entity_add(character, DamageOverTime.{damage_per_tick = 10, ticks_remaining = 3});

    for 1..3 {
        print("\nTick %:\n", it);
        process_dot(character);
        print("Health after DoT tick: %\n", entity_get(character, _Health).value);
    }
}