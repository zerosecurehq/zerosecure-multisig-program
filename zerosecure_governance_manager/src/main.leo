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

import zero_wallet_manager_v7.aleo;

program zero_governance_manager_v7.aleo {

    const MAX_OWNERS: u8 = 8u8;
    const ZERO_ADDRESS: address = aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc;

    record ConfirmChangeGovernanceTicket {
        owner: address,
        request_id: field,
        wallet_address: address,
        sequence: u64,
        new_owners: [address; 8],
        new_threshold: u8,
        old_threshold: u8,
    }

    record ExecuteChangeGovernanceTicket {
        owner: address,
        request_id: field,
        wallet_address: address,
        sequence: u64,
        new_owners: [address; 8],
        new_threshold: u8,
        old_threshold: u8,
    }

    struct ChangeGovernanceStatus {
        confirmations: u8,
    }

    mapping has_pending_change_governance: field => bool; // hash_to_field(wallet_address) => bool;
    mapping change_governance_status: field => ChangeGovernanceStatus; // request_id => ChangeGovernanceStatus;

    /**
        * Change the governance of a wallet
        * @param wallet The wallet to change the governance of
        * @param request_id The request id of the change governance request (random field submitted by the caller)
        * @param new_owners The new owners of the wallet (if not changing, set to the current owners)
        * @param new_threshold The new threshold of the wallet (if not changing, set to the current threshold)
        * @return The wallet record retunred back for caller, the execute change governance ticket (for caller), the confirm change governance ticket (for each owner), and a future to finalize the change governance
    */
    async transition change_governance(wallet: zero_wallet_manager_v7.aleo/Wallet, request_id: field, new_owners: [address; 8], new_threshold: u8) -> (zero_wallet_manager_v7.aleo/Wallet, ExecuteChangeGovernanceTicket, ConfirmChangeGovernanceTicket, ConfirmChangeGovernanceTicket, ConfirmChangeGovernanceTicket, ConfirmChangeGovernanceTicket, ConfirmChangeGovernanceTicket, ConfirmChangeGovernanceTicket, ConfirmChangeGovernanceTicket, ConfirmChangeGovernanceTicket, Future) {
        // check either new_owners or new_threshold should differ from the current wallet
        assert_eq(new_owners != wallet.owners || new_threshold != wallet.threshold, true);

        // check if the new_threshold is within the range of the new_owners
        let non_zero_owners: u8 = 0u8;
        for i: u8 in 0u8..MAX_OWNERS {
           non_zero_owners += (new_owners[i] != ZERO_ADDRESS ? 1u8 : 0u8);
        }
        assert_eq(new_threshold <= non_zero_owners && new_threshold >= 1u8, true);

        let wallet_address_hashed_to_field: field = BHP256::hash_to_field(wallet.wallet_address);

        let confirm_ticket_1: ConfirmChangeGovernanceTicket = ConfirmChangeGovernanceTicket {
            owner: wallet.owner == wallet.owners[0u8] ? ZERO_ADDRESS : wallet.owners[0u8],
            request_id: request_id,
            wallet_address: wallet.wallet_address,
            sequence: wallet.sequence,
            new_owners: new_owners,
            new_threshold: new_threshold,
            old_threshold: wallet.threshold,
        };

        let confirm_ticket_2: ConfirmChangeGovernanceTicket = ConfirmChangeGovernanceTicket {
            owner: wallet.owner == wallet.owners[1u8] ? ZERO_ADDRESS : wallet.owners[1u8],
            request_id: request_id,
            wallet_address: wallet.wallet_address,
            sequence: wallet.sequence,
            new_owners: new_owners,
            new_threshold: new_threshold,
            old_threshold: wallet.threshold,
        };

        let confirm_ticket_3: ConfirmChangeGovernanceTicket = ConfirmChangeGovernanceTicket {
            owner: wallet.owner == wallet.owners[2u8] ? ZERO_ADDRESS : wallet.owners[2u8],
            request_id: request_id,
            wallet_address: wallet.wallet_address,
            sequence: wallet.sequence,
            new_owners: new_owners,
            new_threshold: new_threshold,
            old_threshold: wallet.threshold,
        };

        let confirm_ticket_4: ConfirmChangeGovernanceTicket = ConfirmChangeGovernanceTicket {
            owner: wallet.owner == wallet.owners[3u8] ? ZERO_ADDRESS : wallet.owners[3u8],
            request_id: request_id,
            wallet_address: wallet.wallet_address,
            sequence: wallet.sequence,
            new_owners: new_owners,
            new_threshold: new_threshold,
            old_threshold: wallet.threshold,
        };

        let confirm_ticket_5: ConfirmChangeGovernanceTicket = ConfirmChangeGovernanceTicket {
            owner: wallet.owner == wallet.owners[4u8] ? ZERO_ADDRESS : wallet.owners[4u8],
            request_id: request_id,
            wallet_address: wallet.wallet_address,
            sequence: wallet.sequence,
            new_owners: new_owners,
            new_threshold: new_threshold,
            old_threshold: wallet.threshold,
        };

        let confirm_ticket_6: ConfirmChangeGovernanceTicket = ConfirmChangeGovernanceTicket {
            owner: wallet.owner == wallet.owners[5u8] ? ZERO_ADDRESS : wallet.owners[5u8],
            request_id: request_id,
            wallet_address: wallet.wallet_address,
            sequence: wallet.sequence,
            new_owners: new_owners,
            new_threshold: new_threshold,
            old_threshold: wallet.threshold,
        };

        let confirm_ticket_7: ConfirmChangeGovernanceTicket = ConfirmChangeGovernanceTicket {
            owner: wallet.owner == wallet.owners[6u8] ? ZERO_ADDRESS : wallet.owners[6u8],
            request_id: request_id,
            wallet_address: wallet.wallet_address,
            sequence: wallet.sequence,
            new_owners: new_owners,
            new_threshold: new_threshold,
            old_threshold: wallet.threshold,
        };

        let confirm_ticket_8: ConfirmChangeGovernanceTicket = ConfirmChangeGovernanceTicket {
            owner: wallet.owner == wallet.owners[7u8] ? ZERO_ADDRESS : wallet.owners[7u8],
            request_id: request_id,
            wallet_address: wallet.wallet_address,
            sequence: wallet.sequence,
            new_owners: new_owners,
            new_threshold: new_threshold,
            old_threshold: wallet.threshold,
        };

        let execute_ticket: ExecuteChangeGovernanceTicket = ExecuteChangeGovernanceTicket {
            owner: wallet.owner,
            request_id: request_id,
            wallet_address: wallet.wallet_address,
            sequence: wallet.sequence,
            new_owners: new_owners,
            new_threshold: new_threshold,
            old_threshold: wallet.threshold,
        };

        let new_wallet: zero_wallet_manager_v7.aleo/Wallet = zero_wallet_manager_v7.aleo/refresh_wallet_record(wallet);
        let caller_wallet_hashed_to_field: field = BHP256::hash_to_field(wallet.owner);

        return (new_wallet, execute_ticket, confirm_ticket_1, confirm_ticket_2, confirm_ticket_3, confirm_ticket_4, confirm_ticket_5, confirm_ticket_6, confirm_ticket_7, confirm_ticket_8, finalize_change_governance(wallet_address_hashed_to_field, request_id, caller_wallet_hashed_to_field, wallet.sequence));
    }

    async function finalize_change_governance(wallet_address_hashed_to_field: field, request_id: field, caller_wallet_hashed_to_field: field, caller_sequence: u64) {
        // make sure only 1 request is allowed at a time
        assert_eq(Mapping::contains(has_pending_change_governance, wallet_address_hashed_to_field), false);

        // make sure request_id is unique
        assert_eq(Mapping::contains(change_governance_status, request_id), false);
        
        // make sure caller sequence is latest
        let onchain_wallet_sequence: u64 = Mapping::get(zero_wallet_manager_v7.aleo/wallet_sequence, wallet_address_hashed_to_field);
        assert_eq(onchain_wallet_sequence == caller_sequence, true);

        //make sure caller is the manager of the wallet or admin
        let admin_wallet_hashed_to_field: field = Mapping::get(zero_wallet_manager_v7.aleo/admins, wallet_address_hashed_to_field);
        let managers: [field; 8] = Mapping::get(zero_wallet_manager_v7.aleo/managers, wallet_address_hashed_to_field);
        assert_eq(is_contains(managers, caller_wallet_hashed_to_field) || admin_wallet_hashed_to_field == caller_wallet_hashed_to_field, true);
        
        Mapping::set(has_pending_change_governance, wallet_address_hashed_to_field, true);
        Mapping::set(change_governance_status, request_id, ChangeGovernanceStatus { confirmations: 1u8 });
    }

    /**
        * Confirm a change governance request
        * @param ticket The confirm change governance ticket
        * @return The execute change governance ticket and a future to finalize the confirm governance (+1 confirmation)
    */
    async transition confirm_change_governance(ticket: ConfirmChangeGovernanceTicket) -> (ExecuteChangeGovernanceTicket, Future) {
        let execute_ticket: ExecuteChangeGovernanceTicket = ExecuteChangeGovernanceTicket {
            owner: ticket.owner,
            request_id: ticket.request_id,
            wallet_address: ticket.wallet_address,
            sequence: ticket.sequence,
            new_owners: ticket.new_owners,
            new_threshold: ticket.new_threshold,
            old_threshold: ticket.old_threshold,
        };
        return (execute_ticket, finalize_confirm_governance(ticket.request_id));
    }

    async function finalize_confirm_governance(request_id: field) {
        let status: ChangeGovernanceStatus = Mapping::get(change_governance_status, request_id);
        Mapping::set(change_governance_status, request_id, ChangeGovernanceStatus { confirmations: status.confirmations + 1u8 });
    }

    /**
        * Execute a change governance request
        * @param ticket The execute change governance ticket
        * @return The new wallet records for each owner and a future to finalize the execute governance (increase sequence)
    */
    async transition execute_change_governance(ticket: ExecuteChangeGovernanceTicket) -> (zero_wallet_manager_v7.aleo/Wallet, zero_wallet_manager_v7.aleo/Wallet, zero_wallet_manager_v7.aleo/Wallet, zero_wallet_manager_v7.aleo/Wallet, zero_wallet_manager_v7.aleo/Wallet, zero_wallet_manager_v7.aleo/Wallet, zero_wallet_manager_v7.aleo/Wallet, zero_wallet_manager_v7.aleo/Wallet, Future) {
        let new_owners: [address; 8] = ticket.new_owners;
        let new_wallet_1: zero_wallet_manager_v7.aleo/Wallet = zero_wallet_manager_v7.aleo/create_new_wallet_record(new_owners[0u8], ticket.wallet_address, new_owners, ticket.new_threshold, ticket.sequence + 1u64);
        let new_wallet_2: zero_wallet_manager_v7.aleo/Wallet = zero_wallet_manager_v7.aleo/create_new_wallet_record(new_owners[1u8], ticket.wallet_address, new_owners, ticket.new_threshold, ticket.sequence + 1u64);
        let new_wallet_3: zero_wallet_manager_v7.aleo/Wallet = zero_wallet_manager_v7.aleo/create_new_wallet_record(new_owners[2u8], ticket.wallet_address, new_owners, ticket.new_threshold, ticket.sequence + 1u64);
        let new_wallet_4: zero_wallet_manager_v7.aleo/Wallet = zero_wallet_manager_v7.aleo/create_new_wallet_record(new_owners[3u8], ticket.wallet_address, new_owners, ticket.new_threshold, ticket.sequence + 1u64);
        let new_wallet_5: zero_wallet_manager_v7.aleo/Wallet = zero_wallet_manager_v7.aleo/create_new_wallet_record(new_owners[4u8], ticket.wallet_address, new_owners, ticket.new_threshold, ticket.sequence + 1u64);
        let new_wallet_6: zero_wallet_manager_v7.aleo/Wallet = zero_wallet_manager_v7.aleo/create_new_wallet_record(new_owners[5u8], ticket.wallet_address, new_owners, ticket.new_threshold, ticket.sequence + 1u64);
        let new_wallet_7: zero_wallet_manager_v7.aleo/Wallet = zero_wallet_manager_v7.aleo/create_new_wallet_record(new_owners[6u8], ticket.wallet_address, new_owners, ticket.new_threshold, ticket.sequence + 1u64);
        let new_wallet_8: zero_wallet_manager_v7.aleo/Wallet = zero_wallet_manager_v7.aleo/create_new_wallet_record(new_owners[7u8], ticket.wallet_address, new_owners, ticket.new_threshold, ticket.sequence + 1u64);

        let increase_sequence_function: Future = zero_wallet_manager_v7.aleo/increase_sequence(ticket.wallet_address);
        let wallet_address_hashed_to_field: field = BHP256::hash_to_field(ticket.wallet_address);

        return (new_wallet_1, new_wallet_2, new_wallet_3, new_wallet_4, new_wallet_5, new_wallet_6, new_wallet_7, new_wallet_8, finalize_execute_governance(wallet_address_hashed_to_field, ticket.request_id, ticket.sequence, ticket.old_threshold, increase_sequence_function));
    }

    async function finalize_execute_governance(wallet_address_hashed_to_field: field, request_id: field, ticket_sequence: u64, old_threshold: u8, increase_sequence_function: Future) {
        // check if the pending change threshold is true
        assert_eq(Mapping::get(has_pending_change_governance, wallet_address_hashed_to_field), true);
     
        // check if the confirmations are greater than or equal to the old threshold
        let status: ChangeGovernanceStatus = Mapping::get(change_governance_status, request_id);
        assert_eq(status.confirmations >= old_threshold, true);

        // check if the sequence is the same as the ticket sequence
        let onchain_wallet_sequence: u64 = Mapping::get(zero_wallet_manager_v7.aleo/wallet_sequence, wallet_address_hashed_to_field);
        assert_eq(onchain_wallet_sequence == ticket_sequence, true);

        Mapping::remove(change_governance_status, request_id);
        Mapping::remove(has_pending_change_governance, wallet_address_hashed_to_field);

        increase_sequence_function.await();
    }

    //////////////////// Utility functions ////////////////////
    inline is_contains(array: [field; 8], element: field) -> bool {
        for i:u8 in 0u8..MAX_OWNERS {
            if array[i] == element {
                return true;
            }
        }
        return false;
    }
}
