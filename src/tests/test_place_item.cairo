#[cfg(test)]
mod tests {
    use starknet::class_hash::Felt252TryIntoClassHash;

    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // import test utils
    use warpack_masters::{
        systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}},
        models::backpack::{Backpack, backpack, BackpackGrids, Grid, GridTrait},
        models::Item::{Item, item, ItemsCounter},
        models::CharacterItem::{CharacterItem, Position, CharacterItemsCounter},
        models::Character::{Character, character, Class},
    };

    use warpack_masters::systems::actions::actions::ITEMS_COUNTER_ID;


    #[test]
    #[available_gas(3000000000000000)]
    fn test_place_item() {
        let player = starknet::contract_address_const::<0x0>();

        let mut models = array![
            backpack::TEST_CLASS_HASH, item::TEST_CLASS_HASH, character::TEST_CLASS_HASH
        ];

        let world = spawn_test_world(models);

        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address };

        actions_system.spawn('Alice', Class::Warlock);

        actions_system.add_item('Sword', 1, 3, 100, 10, 10, 5, 10, 5, 9);
        actions_system.add_item('Shield', 2, 2, 50, 0, 5, 5, 10, 5, 9);
        actions_system.add_item('Potion', 1, 1, 20, 0, 0, 5, 10, 15, 9);

        let item = get!(world, ITEMS_COUNTER_ID, ItemsCounter);
        assert(item.count == 3, 'total item count mismatch');
        // place a sword on (0,4)
        actions_system.place_item(1, 0, 4, 0);
        // (0,4) (0,5) (0,6) should be occupied
        let mut backpack_grid_data = get!(world, (player, 0, 4), BackpackGrids);
        assert(backpack_grid_data.occupied == true, '(0,4) should be occupied');

        let mut backpack_grid_data = get!(world, (player, 0, 5), BackpackGrids);
        assert(backpack_grid_data.occupied == true, '(0,5) should be occupied');

        let mut backpack_grid_data = get!(world, (player, 0, 6), BackpackGrids);
        assert(backpack_grid_data.occupied == true, '(0,6) should be occupied');

        let mut characterItemsCounter = get!(world, player, CharacterItemsCounter);
        let characterItem = get!(world, (player, characterItemsCounter.count), CharacterItem);
        assert(characterItem.itemId == characterItemsCounter.count, 'item id should equal count');
        assert(characterItem.where == 'inventory', 'item should be in inventory');
        assert(characterItem.position.x == 0, 'x position mismatch');
        assert(characterItem.position.y == 4, 'y position mismatch');
        assert(characterItem.rotation == 0, 'rotation mismatch');

        // place a shield on (1,5)
        actions_system.place_item(2, 1, 5, 0);
        // (1,5) (1,6) (2,5) (2,6) should be occupied
        let mut backpack_grid_data = get!(world, (player, 1, 5), BackpackGrids);
        assert(backpack_grid_data.occupied == true, '(1,5) should be occupied');

        let mut backpack_grid_data = get!(world, (player, 1, 6), BackpackGrids);
        assert(backpack_grid_data.occupied == true, '(1,6) should be occupied');

        let mut backpack_grid_data = get!(world, (player, 2, 5), BackpackGrids);
        assert(backpack_grid_data.occupied == true, '(2,5) should be occupied');

        let mut backpack_grid_data = get!(world, (player, 2, 6), BackpackGrids);
        assert(backpack_grid_data.occupied == true, '(2,6) should be occupied');

        characterItemsCounter = get!(world, player, CharacterItemsCounter);
        let characterItem = get!(world, (player, characterItemsCounter.count), CharacterItem);
        assert(characterItem.itemId == characterItemsCounter.count, 'item id should equal count');
        assert(characterItem.where == 'inventory', 'item should be in inventory');
        assert(characterItem.position.x == 1, 'x position mismatch');
        assert(characterItem.position.y == 5, 'y position mismatch');
        assert(characterItem.rotation == 0, 'rotation mismatch');

        // place a potion on (1,4)
        actions_system.place_item(3, 1, 4, 0);
        // (1,4) should be occupied
        let mut backpack_grid_data = get!(world, (player, 1, 4), BackpackGrids);
        assert(backpack_grid_data.occupied == true, '(1,4) should be occupied');

        characterItemsCounter = get!(world, player, CharacterItemsCounter);
        let characterItem = get!(world, (player, characterItemsCounter.count), CharacterItem);
        // assert(characterItem.itemId == characterItemsCounter.count, 'item id should equal count');
        assert(characterItem.where == 'inventory', 'item should be in inventory');
        assert(characterItem.position.x == 1, 'x position mismatch');
        assert(characterItem.position.y == 4, 'y position mismatch');
        assert(characterItem.rotation == 0, 'rotation mismatch');
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('x out of range', 'ENTRYPOINT_FAILED'))]
    fn test_place_item_revert_x_out_of_range() {
        let player = starknet::contract_address_const::<0x0>();

        let mut models = array![
            backpack::TEST_CLASS_HASH, item::TEST_CLASS_HASH, character::TEST_CLASS_HASH
        ];

        let world = spawn_test_world(models);

        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address };

        actions_system.spawn('Alice', Class::Warlock);

        actions_system.add_item('Sword', 1, 3, 100, 10, 10, 5, 10, 5, 9);

        // place a sword on (10,0)
        actions_system.place_item(1, 10, 0, 0);
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('y out of range', 'ENTRYPOINT_FAILED'))]
    fn test_place_item_revert_y_out_of_range() {
        let player = starknet::contract_address_const::<0x0>();

        let mut models = array![
            backpack::TEST_CLASS_HASH, item::TEST_CLASS_HASH, character::TEST_CLASS_HASH
        ];

        let world = spawn_test_world(models);

        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address };

        actions_system.spawn('Alice', Class::Warlock);

        actions_system.add_item('Sword', 1, 3, 100, 10, 10, 5, 10, 5, 9);

        // place a sword on (0,10)
        actions_system.place_item(1, 0, 10, 0);
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('invalid rotation', 'ENTRYPOINT_FAILED'))]
    fn test_place_item_revert_invalid_rotation() {
        let player = starknet::contract_address_const::<0x0>();

        let mut models = array![
            backpack::TEST_CLASS_HASH, item::TEST_CLASS_HASH, character::TEST_CLASS_HASH
        ];

        let world = spawn_test_world(models);

        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address };

        actions_system.spawn('Alice', Class::Warlock);

        actions_system.add_item('Sword', 1, 3, 100, 10, 10, 5, 10, 5, 9);

        // place a sword on (0,0) with rotation 30
        actions_system.place_item(1, 0, 0, 30);
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('item out of bound for x', 'ENTRYPOINT_FAILED'))]
    fn test_place_item_revert_x_OOB() {
        let player = starknet::contract_address_const::<0x0>();

        let mut models = array![
            backpack::TEST_CLASS_HASH, item::TEST_CLASS_HASH, character::TEST_CLASS_HASH
        ];

        let world = spawn_test_world(models);

        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address };

        actions_system.spawn('Alice', Class::Warlock);

        actions_system.add_item('Sword', 1, 3, 100, 10, 10, 5, 10, 5, 9);

        // place a sword on (8,6) with rotation 90
        actions_system.place_item(1, 8, 6, 90);
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('item out of bound for y', 'ENTRYPOINT_FAILED'))]
    fn test_place_item_revert_y_OOB() {
        let player = starknet::contract_address_const::<0x0>();

        let mut models = array![
            backpack::TEST_CLASS_HASH, item::TEST_CLASS_HASH, character::TEST_CLASS_HASH
        ];

        let world = spawn_test_world(models);

        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address };

        actions_system.spawn('Alice', Class::Warlock);

        actions_system.add_item('Sword', 1, 3, 100, 10, 10, 5, 10, 5, 9);

        // place a sword on (0,6)
        actions_system.place_item(1, 0, 6, 0);
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('Already occupied', 'ENTRYPOINT_FAILED'))]
    fn test_place_item_revert_occupied_grids() {
        let player = starknet::contract_address_const::<0x0>();

        let mut models = array![
            backpack::TEST_CLASS_HASH, item::TEST_CLASS_HASH, character::TEST_CLASS_HASH
        ];

        let world = spawn_test_world(models);

        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address };

        actions_system.spawn('Alice', Class::Warlock);

        actions_system.add_item('Sword', 1, 3, 100, 10, 10, 5, 10, 5, 9);

        // place a sword on (0,4)
        actions_system.place_item(1, 0, 4, 0);

        // try to place the sword again on of the occupied grids
        // this will collide with grid (0,4) and (0,5)
        actions_system.place_item(1, 0, 3, 0);
    }
}
