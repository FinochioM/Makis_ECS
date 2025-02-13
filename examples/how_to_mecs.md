# MECS (Makis ECS) Library Documentation

## Core Initialization (REQUIRED)

Two initialization steps are required for the library to work:

1. Compile-time initialization with `@init_recs`:
```jai
@init_recs();  // Default: 1000 max entities, 30 max components
// or
@init_recs(2000, 50, true);  // Custom: max entities, max components, assertions
```

2. Runtime initialization with `init_ecs` in main:
```jai
main :: () {
    init_ecs();  // REQUIRED! Must be the first line in main()
    // ... rest of your code
}
```

IMPORTANT: Forgetting to call `init_ecs()` at the start of main will cause crashes when trying to use any ECS functionality!

## Core Macros

### @comp
Creates a basic component type. Used for void components or existing types.
```jai
Position :: @comp Vector2;     // Using existing type
Renderable :: @comp void;      // Simple flag component
```

### @comp struct
Creates a component from a custom struct definition. Used for components that need multiple fields.
```jai
Health :: @comp struct {       // Custom structured component
    value: float32;
    max_value: float32;
};
```

### @init_components
Registers components with the ECS system. Must be called after component definitions.
```jai
@init_components(Position, Health, Renderable);
```

### @group
Creates a group of components for easier entity management and querying.
```jai
Movement :: @group(Position, Velocity);
```

## Component Operations

### Component Access
When getting component data, use the underscore prefix (`_ComponentName`). This is an auto-generated compile-time helper.
```jai
// CORRECT:
health := entity_get(entity, _Health);         // Getting component data
pos := entity_get(entity, _Position);

// INCORRECT:
health := entity_get(entity, Health);          // Won't compile
health := entity_get(entity, .Health);         // Won't compile
```

### Component Addition
When adding components, use the component type directly.
```jai
entity_add(entity, Health.{100, 100});         // Struct components
entity_add(entity, Position.{x=10, y=20});     // Vector2 component
entity_add(entity, Renderable);                // Void component
```

### Component Updates
```jai
health := entity_get(entity, _Health);
health.value -= 10;
entity_update(entity, health);
```

### Component Removal
```jai
entity_remove(entity, _Health);
```

## Entity Management

### Creating Entities
```jai
entity := create_entity();                     // Empty entity
entity := create_entity(Movement);             // With component group
```

### Checking Components
```jai
has_health := entity_have(entity, _Health);
has_all := entity_have_all(entity, .Position, .Velocity);
has_any := entity_have_any(entity, .Health, .Shield);
```

## Events

### Defining Events
```jai
EVENT_DAMAGE :: 1;    // Events are just unique integers
```

### Event Handling
```jai
on_damage :: (entity: Entity, data: *void) -> bool {
    return true;  // Return true if event was handled
}

// Subscribe to events
subscribe(EVENT_DAMAGE, on_damage);

// Emit events
emit(EVENT_DAMAGE, entity);
```

## Important Notes

1. Initialization Order
   - Always `@init_recs()` at file start for compile-time setup
   - Always `init_ecs()` at start of main for runtime initialization
   - Then define components
   - Then `@init_components()`
   - Then rest of code

2. Numeric Components
   - Wrap primitive types in structs for better type safety
   - Example: `Health :: @comp struct { value: float32; };` instead of `Health :: @comp float32;`

3. Working with Groups
   - Register groups before using them: `register_group(Movement);`
   - Groups can be used in entity creation and system queries