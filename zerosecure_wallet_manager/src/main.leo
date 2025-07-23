/**
 * SPDX-License-Identifier: MIT
 *
 * This software is licensed under the MIT License.  
 *  
 * Copyright (c) 2025 ZeroSecure
 *  
 * Permission is hereby granted, free of charge, to any person obtaining a copy  
 * of this software and associated documentation files (the "Software"), to deal  
 * in the Software without restriction, including without limitation the rights  
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
 * copies of the Software, and to permit persons to whom the Software is  
 * furnished to do so, subject to the following conditions:  
 *  
 * The above copyright notice and this permission notice shall be included in all  
 * copies or substantial portions of the Software.  
 *  
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
 * FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL THE  
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER  
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM,  
 * OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN  
 * THE SOFTWARE.  
 */

program zero_wallet_manager_v7.aleo {
    
    const MAX_OWNERS: u8 = 8u8;
    const ZERO_ADDRESS: address = aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc;
    const CREDITS_RESERVED_TOKEN_ID: field = 3443843282313283355522573239085696902919850365217539366784739393210722344986field;

    record Wallet {
        owner: address,
        wallet_address: address,
        owners: [address; 8],
        threshold: u8,
        sequence: u64,
    }

    // wallet_sequence is used to determine if Wallet is outdated
    mapping wallet_sequence: field => u64; // hash_to_field(wallet_address) => u64;
    mapping managers: field => [field; 8]; // hash_to_field(wallet_address) => [hash_to_field(owner); 8];
    mapping admins: field => field; // hash_to_field(wallet_address) => hash_to_field(owner);

    /**
        * Create a new multisig wallet
        * @param wallet_address The address of the wallet (random address, submitted by the caller)
        * @param owners The owners of the wallet (up to 8, ZERO_ADDRESS if not used)
        * @param threshold The threshold of the wallet
        * @return Wallet The wallet created for each owner and the future (set the sequence to 0)
    */
    async transition create_wallet(wallet_address: address, owners: [address; 8], threshold: u8) -> (Wallet, Wallet, Wallet, Wallet, Wallet, Wallet, Wallet, Wallet, Future) {
        // check if the threshold is valid
        let non_zero_owners: u8 = 0u8;
        for i:u8 in 0u8..MAX_OWNERS {
           // TODO: bring normal == when leo fix this bug
           non_zero_owners += (!(owners[i] == ZERO_ADDRESS) ? 1u8 : 0u8);
        }
        assert_eq(threshold <= non_zero_owners && threshold >= 1u8, true);
        
        let wallet_record_1: Wallet = Wallet {
            owner: owners[0u8],
            wallet_address: wallet_address,
            owners: owners,
            threshold: threshold,
            sequence: 0u64,
        };

        let wallet_record_2: Wallet = Wallet {
            owner: owners[1u8],
            wallet_address: wallet_address,
            owners: owners,
            threshold: threshold,
            sequence: 0u64,
        };

        let wallet_record_3: Wallet = Wallet {
            owner: owners[2u8],
            wallet_address: wallet_address,
            owners: owners,
            threshold: threshold,
            sequence: 0u64,
        };

        let wallet_record_4: Wallet = Wallet {
            owner: owners[3u8],
            wallet_address: wallet_address,
            owners: owners,
            threshold: threshold,
            sequence: 0u64,
        };

        let wallet_record_5: Wallet = Wallet {
            owner: owners[4u8],
            wallet_address: wallet_address,
            owners: owners,
            threshold: threshold,
            sequence: 0u64,
        };

        let wallet_record_6: Wallet = Wallet {
            owner: owners[5u8],
            wallet_address: wallet_address,
            owners: owners,
            threshold: threshold,
            sequence: 0u64,
        };

        let wallet_record_7: Wallet = Wallet {
            owner: owners[6u8],
            wallet_address: wallet_address,
            owners: owners,
            threshold: threshold,
            sequence: 0u64,
        };

        let wallet_record_8: Wallet = Wallet {
            owner: owners[7u8],
            wallet_address: wallet_address,
            owners: owners,
            threshold: threshold,
            sequence: 0u64,
        };

        let wallet_address_hashed_to_field: field = BHP256::hash_to_field(wallet_address);
        let caller_wallet_hashed_to_field: field = BHP256::hash_to_field(self.caller);

        return (wallet_record_1, wallet_record_2, wallet_record_3, wallet_record_4, wallet_record_5, wallet_record_6, wallet_record_7, wallet_record_8, finalize_create_wallet(wallet_address_hashed_to_field, caller_wallet_hashed_to_field));
    }

    async function finalize_create_wallet(wallet_address_hashed_to_field: field, caller_wallet_hashed_to_field: field) {
        assert_eq(Mapping::contains(wallet_sequence, wallet_address_hashed_to_field), false);
        Mapping::set(wallet_sequence, wallet_address_hashed_to_field, 0u64);

        Mapping::set(admins, wallet_address_hashed_to_field, caller_wallet_hashed_to_field);
        Mapping::set(managers, wallet_address_hashed_to_field, [
            BHP256::hash_to_field(ZERO_ADDRESS),
            BHP256::hash_to_field(ZERO_ADDRESS),
            BHP256::hash_to_field(ZERO_ADDRESS),
            BHP256::hash_to_field(ZERO_ADDRESS),
            BHP256::hash_to_field(ZERO_ADDRESS),
            BHP256::hash_to_field(ZERO_ADDRESS),
            BHP256::hash_to_field(ZERO_ADDRESS),
            BHP256::hash_to_field(ZERO_ADDRESS),
        ]);
    }
    
    /**
        * Change the managers of the wallet
        * @param wallet The wallet to change the managers of
        * @param new_managers The new managers of the wallet (up to 8, ZERO_ADDRESS if not used)
        * @return Future The future of the change managers
    */
    async transition change_managers(wallet: Wallet, new_managers: [address; 8]) -> (Wallet, Future) {        
        let wallet_address_hashed_to_field: field = BHP256::hash_to_field(wallet.wallet_address);
        let caller_wallet_hashed_to_field: field = BHP256::hash_to_field(wallet.owner);
        let new_managers_hashed_to_field: [field; 8] = [
            BHP256::hash_to_field(new_managers[0u8]),
            BHP256::hash_to_field(new_managers[1u8]),
            BHP256::hash_to_field(new_managers[2u8]),
            BHP256::hash_to_field(new_managers[3u8]),
            BHP256::hash_to_field(new_managers[4u8]),
            BHP256::hash_to_field(new_managers[5u8]),
            BHP256::hash_to_field(new_managers[6u8]),
            BHP256::hash_to_field(new_managers[7u8]),
            ];
            
        let new_wallet: Wallet = Wallet {
            owner: wallet.owner,
            wallet_address: wallet.wallet_address,
            owners: wallet.owners,
            threshold: wallet.threshold,
            sequence: wallet.sequence,
        };
        return (new_wallet, finalize_change_managers(wallet_address_hashed_to_field, caller_wallet_hashed_to_field, new_managers_hashed_to_field));
    }

    async function finalize_change_managers(wallet_address_hashed_to_field: field, caller_wallet_hashed_to_field: field, new_managers_hashed_to_field: [field; 8]) {
        // make sure only admins can call this function
        let admin_wallet_hashed_to_field: field = Mapping::get(admins, wallet_address_hashed_to_field);
        assert_eq(admin_wallet_hashed_to_field, caller_wallet_hashed_to_field);
        // set the new managers
        Mapping::set(managers, wallet_address_hashed_to_field, new_managers_hashed_to_field);
    }

    async transition change_admin(wallet: Wallet, new_admin: address) -> (Wallet, Future) {
        let wallet_address_hashed_to_field: field = BHP256::hash_to_field(wallet.wallet_address);
        let caller_wallet_hashed_to_field: field = BHP256::hash_to_field(wallet.owner);
        let new_admin_hashed_to_field: field = BHP256::hash_to_field(new_admin);

        assert_eq(is_contains(wallet.owners, new_admin), true);
        // make sure the new admin is not the same as the current admin
        assert_eq(new_admin == wallet.owner, false);
        // make sure the new admin is not ZERO_ADDRESS
        assert_eq(new_admin == ZERO_ADDRESS, false);

        let new_wallet: Wallet = Wallet {
            owner: wallet.owner,
            wallet_address: wallet.wallet_address,
            owners: wallet.owners,
            threshold: wallet.threshold,
            sequence: wallet.sequence,
        };
        return (new_wallet, finalize_change_admin(wallet_address_hashed_to_field, caller_wallet_hashed_to_field, new_admin_hashed_to_field));
    }

    async function finalize_change_admin(wallet_address_hashed_to_field: field, caller_wallet_hashed_to_field: field, new_admin_hashed_to_field: field) {
        // make sure only admins can call this function
        let admin_wallet_hashed_to_field: field = Mapping::get(admins, wallet_address_hashed_to_field);
        assert_eq(admin_wallet_hashed_to_field, caller_wallet_hashed_to_field);
        // set the new admin
        Mapping::set(admins, wallet_address_hashed_to_field, new_admin_hashed_to_field);
    }

    /**
        * Increase the sequence of the wallet
        * @param wallet_address The address of the wallet
        * @return Future The future of the increase sequence (set the sequence to sequence + 1)
    */
    async transition increase_sequence(wallet_address: address) -> Future {
        // make sure only the zerosecure_governance_manager program can call this function
        assert_eq(self.caller, zero_governance_manager_v7.aleo);

        let wallet_address_hashed_to_field: field = BHP256::hash_to_field(wallet_address);
        return finalize_increase_sequence(wallet_address_hashed_to_field);
    }

    async function finalize_increase_sequence(wallet_address_hashed_to_field: field) {
        let current_sequence: u64 = Mapping::get(wallet_sequence, wallet_address_hashed_to_field);
        Mapping::set(wallet_sequence, wallet_address_hashed_to_field, current_sequence + 1u64);
    }

    transition refresh_wallet_record(wallet: Wallet) -> Wallet {
        return Wallet {
            owner: wallet.owner,
            wallet_address: wallet.wallet_address,
            owners: wallet.owners,
            threshold: wallet.threshold,
            sequence: wallet.sequence,
        };
    }

    transition create_new_wallet_record(owner: address, wallet_address: address, owners: [address; 8], threshold: u8, sequence: u64) -> Wallet {
        //make sure only the zerosecure_transfer_manager or zerosecure_governance_manager program can call this function
        let is_transfer_manager: bool = self.caller == zero_transfer_manager_v7.aleo;
        let is_governance_manager: bool = self.caller == zero_governance_manager_v7.aleo;
        assert_eq(is_transfer_manager || is_governance_manager, true);

        return Wallet {
            owner: owner,
            wallet_address: wallet_address,
            owners: owners,
            threshold: threshold,
            sequence: sequence,
        };
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
}
