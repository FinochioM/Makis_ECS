#import "Math";
#import "Basic";

@init_recs();

Health :: @comp struct {
    value: float32;
    max_value: float32;
};

Name :: @comp struct {
    value: string;
};

DamageOverTime :: @comp struct {
    damage_per_tick: float32;
    ticks_remaining: int;
};

@init_components(Health, Name, DamageOverTime, ParentComponent);

EVENT_DEATH :: 1;

on_entity_death :: (entity: Entity, data: *void) -> bool {
    print("Entity '%' has died!\n", entity_get(entity, _Name).value);

    children := get_children(entity);

    for children {
        child := it;
        if entity_have(child, .Health) {
            print("Child '%' takes 25 damage from parent's death\n",
                  entity_get(child, _Name).value);
            apply_damage(child, 25);
        }
    }

    array_free(children);
    return true;
}

apply_damage :: (entity: Entity, amount: float32) {
    health := entity_get(entity, _Health);
    health.value = max(cast(float32)0, health.value - amount);
    entity_update(entity, health);
    if health.value <= 0 emit(EVENT_DEATH, entity);
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

print_entity_status :: (entity: Entity) {
    name := entity_get(entity, _Name).value;
    health := entity_get(entity, _Health);
    print("Status of '%': Health: %/%\n",
          name, health.value, health.max_value);
}

main :: () {
    init_ecs();

    subscribe(EVENT_DEATH, on_entity_death);

    boss := create_entity();
    entity_add(boss, Name.{"Boss"});
    entity_add(boss, Health.{100, 100});

    minion1 := create_entity();
    entity_add(minion1, Name.{"Minion 1"});
    entity_add(minion1, Health.{50, 50});
    set_parent(minion1, boss);

    minion2 := create_entity();
    entity_add(minion2, Name.{"Minion 2"});
    entity_add(minion2, Health.{30, 30});
    set_parent(minion2, boss);

    minion3 := create_entity();
    entity_add(minion3, Name.{"Minion 3"});
    entity_add(minion3, Health.{40, 40});
    set_parent(minion3, boss);

    print("\nInitial status:\n");
    print_entity_status(boss);
    for get_children(boss) print_entity_status(it);

    print("\nApplying DoT to boss...\n");
    entity_add(boss, DamageOverTime.{damage_per_tick = 40, ticks_remaining = 3});

    for 1..3 {
        print("\nTick %:\n", it);
        process_dot(boss);

        if entity_have(boss, .Health) {
            print_entity_status(boss);
            for get_children(boss) print_entity_status(it);
        } else {
            print("Boss is defeated!\n");
            break;
        }
    }
}