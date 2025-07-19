import zerosecure_wallet_manager_v5.aleo;

program test_wallet_manager.aleo {

    const MAX_OWNERS: u8 = 8u8;
    const ZERO_ADDRESS: address = aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc;
    const SELF: address = test_wallet_manager.aleo;

    @test 
    transition init () {
    }
    
    @test
    script main() {
        // Test create wallet
        let (w1, w2, w3, w4, w5, w6, w7, w8, create_wallet_future): (
            zerosecure_wallet_manager_v5.aleo/Wallet,
            zerosecure_wallet_manager_v5.aleo/Wallet,
            zerosecure_wallet_manager_v5.aleo/Wallet,
            zerosecure_wallet_manager_v5.aleo/Wallet,
            zerosecure_wallet_manager_v5.aleo/Wallet,
            zerosecure_wallet_manager_v5.aleo/Wallet,
            zerosecure_wallet_manager_v5.aleo/Wallet,
            zerosecure_wallet_manager_v5.aleo/Wallet,
            Future,
            ) = zerosecure_wallet_manager_v5.aleo/create_wallet(
            multi_wallet.aleo,
            [
                SELF,
                owner2.aleo,
                ZERO_ADDRESS,
                ZERO_ADDRESS,
                ZERO_ADDRESS,
                ZERO_ADDRESS,
                ZERO_ADDRESS,
                ZERO_ADDRESS,
            ],
            1u8
        );
        create_wallet_future.await();

        assert_eq(Mapping::get(zerosecure_wallet_manager_v5.aleo/wallet_sequence, BHP256::hash_to_field(multi_wallet.aleo)), 0u64);
        assert_eq(Mapping::get(zerosecure_wallet_manager_v5.aleo/admins, BHP256::hash_to_field(multi_wallet.aleo)), BHP256::hash_to_field(SELF));
        let managers: [field; 8] = Mapping::get(zerosecure_wallet_manager_v5.aleo/managers, BHP256::hash_to_field(multi_wallet.aleo));
        // Note the caller already the admin, so the count should be 8
        assert_eq(count_field_element(managers, BHP256::hash_to_field(ZERO_ADDRESS)), 8u8);
        assert(w1.wallet_address == multi_wallet.aleo);

        // Test change managers
        let new_managers: [address; 8] = [
            SELF,
            ZERO_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS,
        ];

        let (new_wallet_record, change_managers_future): (
            zerosecure_wallet_manager_v5.aleo/Wallet,
            Future,
        ) = zerosecure_wallet_manager_v5.aleo/change_managers(
            w1,
            new_managers,
        );
        change_managers_future.await();

        let new_managers_hashed = Mapping::get(zerosecure_wallet_manager_v5.aleo/managers, BHP256::hash_to_field(multi_wallet.aleo));
        assert_eq(new_managers_hashed, hash_addresses(new_managers));

        // Test change admin
        let (new_wallet_record_2, change_admin_future): (
            zerosecure_wallet_manager_v5.aleo/Wallet,
            Future,
        ) = zerosecure_wallet_manager_v5.aleo/change_admin(
            new_wallet_record,
            owner2.aleo,
        );
        change_admin_future.await();

        assert_eq(Mapping::get(zerosecure_wallet_manager_v5.aleo/admins, BHP256::hash_to_field(multi_wallet.aleo)), BHP256::hash_to_field(owner2.aleo));
    }

    //////////////////// Utility functions ////////////////////
    function is_contains(array: [address; 8], element: address) -> bool {
        for i:u8 in 0u8..MAX_OWNERS {
            if array[i] == element {
                return true;
            }
        }
        return false;
    }

    function hash_addresses(array: [address; 8]) -> [field; 8] {
        let hashes: [field; 8] = [
            BHP256::hash_to_field(array[0]),
            BHP256::hash_to_field(array[1]),
            BHP256::hash_to_field(array[2]),
            BHP256::hash_to_field(array[3]),
            BHP256::hash_to_field(array[4]),
            BHP256::hash_to_field(array[5]),
            BHP256::hash_to_field(array[6]),
            BHP256::hash_to_field(array[7]),
        ];

        return hashes;
    }

    function count_address_element(array: [address; 8], element: address) -> u8 {
        let count: u8 = 0u8;
        for i:u8 in 0u8..MAX_OWNERS {
            if array[i] == element {
                count += 1u8;
            }
        }
        return count;
    }

    function count_field_element(array: [field; 8], element: field) -> u8 {
        let count: u8 = 0u8;
        for i:u8 in 0u8..MAX_OWNERS {
            if array[i] == element {
                count += 1u8;
            }
        }
        return count;
    }
}