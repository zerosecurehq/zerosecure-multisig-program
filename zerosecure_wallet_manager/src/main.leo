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

import credits.aleo;
import token_registry.aleo;

program zerosecure_wallet_manager.aleo {
    
    const MAX_OWNERS:u8 = 8u8;
    const ZERO_ADDRESS:address = aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc;
    const CREDITS_RESERVED_TOKEN_ID: field = 3443843282313283355522573239085696902919850365217539366784739393210722344986field;

    record Wallet {
        owner: address,
        wallet_address: address,
        owners: [address; 8],
        threshold: u8,
        sequence: u64,
    }

    struct BalanceKey {
        wallet_address: address,
        token_id: field,
    }

    mapping balances: field => u128; // hash_to_field(BalanceKey) => u128;
    // wallet_sequence is used to determine if Wallet is outdated
    mapping wallet_sequence: field => u64; // hash_to_field(wallet_address) => u64;

    // // if actual owners is less then MAX_OWNERS, then the rest of the owners are set to ZERO_ADDRESS
    async transition create_wallet(wallet_address: address, owners: [address; 8], threshold: u8) -> (Wallet, Wallet, Wallet, Wallet, Wallet, Wallet, Wallet, Wallet, Future) {
        let non_zero_owners: u8 = 0u8;
        for i:u8 in 0u8..MAX_OWNERS {
           non_zero_owners += (owners[i] != ZERO_ADDRESS ? 1u8 : 0u8);
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

        return (wallet_record_1, wallet_record_2, wallet_record_3, wallet_record_4, wallet_record_5, wallet_record_6, wallet_record_7, wallet_record_8, finalize_create_wallet(wallet_address_hashed_to_field));
    }

    async function finalize_create_wallet(wallet_address_hashed_to_field: field) {
        assert_eq(Mapping::contains(balances, wallet_address_hashed_to_field), false);
        Mapping::set(balances, wallet_address_hashed_to_field, 0u128);
    }

    // use this function with caution, it will reveal who deposited the funds
    async transition deposit_token_public(wallet_address: address, token_id: field, amount: u128) -> Future {
        let balance_key: BalanceKey = BalanceKey {
            wallet_address: wallet_address,
            token_id: token_id,
        };
        let balance_key_hashed: field = BHP256::hash_to_field(balance_key);
        let transfer_function: Future = token_registry.aleo/transfer_public_as_signer(token_id, self.address, amount);
        return finalize_deposit_token_public(balance_key_hashed, amount, transfer_function);
    }

    async function finalize_deposit_token_public(balance_key_hashed: field, amount: u128, transfer_function: Future) {
        let current_balance: u128 = Mapping::get_or_use(balances, balance_key_hashed, 0u128);
        let new_balance: u128 = current_balance + amount;
        Mapping::set(balances, balance_key_hashed, new_balance);
        transfer_function.await();
    }

    async transition deposit_token_private(wallet_address: address, token_id: field, amount: u128, credits: token_registry.aleo/Token) -> (token_registry.aleo/Token, Future) {
        let balance_key: BalanceKey = BalanceKey {
            wallet_address: wallet_address,
            token_id: token_id,
        };
        let balance_key_hashed: field = BHP256::hash_to_field(balance_key);
        let (remaining_credits, transfer_function): (token_registry.aleo/Token, Future) = token_registry.aleo/transfer_private_to_public(self.address, amount, credits);

        return (remaining_credits, finalize_deposit_token_private(balance_key_hashed, amount, transfer_function));
    }

    async function finalize_deposit_token_private(balance_key_hashed: field, amount: u128, transfer_function: Future) {
        let current_balance: u128 = Mapping::get_or_use(balances, balance_key_hashed, 0u128);
        let new_balance: u128 = current_balance + amount;
        Mapping::set(balances, balance_key_hashed, new_balance);
        transfer_function.await();
    }

    // use this function with caution, it will reveal who deposited the funds
    async transition deposit_aleo_public(wallet_address: address, amount: u128) -> Future {
        let balance_key: BalanceKey = BalanceKey {
            wallet_address: wallet_address,
            token_id: CREDITS_RESERVED_TOKEN_ID,
        };
        let balance_key_hashed: field = BHP256::hash_to_field(balance_key);
        let transfer_function: Future = credits.aleo/transfer_public_as_signer(self.address, amount as u64);
        return finalize_deposit_aleo_public(balance_key_hashed, amount, transfer_function);
    }

    async function finalize_deposit_aleo_public(balance_key_hashed: field, amount: u128, transfer_function: Future) {
        let current_balance: u128 = Mapping::get_or_use(balances, balance_key_hashed, 0u128);
        let new_balance: u128 = current_balance + amount;
        Mapping::set(balances, balance_key_hashed, new_balance);
        transfer_function.await();
    }

    async transition deposit_aleo_private(wallet_address: address, amount: u128, credits: credits.aleo/credits) -> (credits.aleo/credits, Future) {
        let balance_key: BalanceKey = BalanceKey {
            wallet_address: wallet_address,
            token_id: CREDITS_RESERVED_TOKEN_ID,
        };
        let balance_key_hashed: field = BHP256::hash_to_field(balance_key);
        let (remaining_credits, transfer_function): (credits.aleo/credits, Future) = credits.aleo/transfer_private_to_public(credits, self.address, amount as u64);

        return (remaining_credits, finalize_deposit_aleo_private(balance_key_hashed, amount, transfer_function));
    }

    async function finalize_deposit_aleo_private(balance_key_hashed: field, amount: u128, transfer_function: Future) {
        let current_balance: u128 = Mapping::get_or_use(balances, balance_key_hashed, 0u128);
        let new_balance: u128 = current_balance + amount;
        Mapping::set(balances, balance_key_hashed, new_balance);
        transfer_function.await();
    }

    transition create_new_wallet(owner: address, wallet_address: address, owners: [address; 8], threshold: u8, sequence: u64) -> Wallet {
        // @TODO: only callable by contract
        return Wallet {
            owner: owner,
            wallet_address: wallet_address,
            owners: owners,
            threshold: threshold,
            sequence: sequence,
        };
    }
    
    // async transition confirm_transfer(confirm_transfer_ticket: ConfirmTransferTicket) -> (ExecuteTransferTicket, Future) {
    //     let execute_transfer_ticket: ExecuteTransferTicket = ExecuteTransferTicket {
    //         owner: confirm_transfer_ticket.owner,
    //         wallet_address: confirm_transfer_ticket.wallet_address,
    //         to: confirm_transfer_ticket.to,
    //         amount: confirm_transfer_ticket.amount,
    //         transfer_id: confirm_transfer_ticket.transfer_id,
    //         threshold: confirm_transfer_ticket.threshold,
    //     };

    //     return (execute_transfer_ticket, finalize_confirm_transfer(confirm_transfer_ticket.transfer_id));
    // }

    // async function finalize_confirm_transfer(transfer_id: field) {
    //     let transfer_status: TransferStatus = Mapping::get(transfers_status, transfer_id);
    //     Mapping::set(transfers_status, transfer_id, TransferStatus {
    //         confirmations: transfer_status.confirmations + 1u8,
    //     });
    // }

    // async transition execute_transfer(execute_transfer_ticket: ExecuteTransferTicket) -> (credits.aleo/credits, Future) {
    //     let wallet_address_hashed_to_field: field = BHP256::hash_to_field(execute_transfer_ticket.wallet_address);
    //     let (receiver_credits, transfer_function): (credits.aleo/credits, Future) = credits.aleo/transfer_public_to_private(execute_transfer_ticket.to, execute_transfer_ticket.amount);
        
    //     return (receiver_credits, finalize_execute_transfer(wallet_address_hashed_to_field, execute_transfer_ticket.transfer_id, execute_transfer_ticket.threshold, execute_transfer_ticket.amount, transfer_function));
    // }

    // async function finalize_execute_transfer(wallet_address_hashed_to_field: field, transfer_id: field, threshold: u8, amount: u64, transfer_function: Future) {
    //     let onchain_transfer_status: TransferStatus = Mapping::get(transfers_status, transfer_id);
    //     assert_eq(onchain_transfer_status.confirmations >= threshold, true);

    //     // check if the wallet has enough balance
    //     let current_balance: u64 = Mapping::get(balances, wallet_address_hashed_to_field);
    //     assert_eq(current_balance >= amount, true);

    //     // set the new balance
    //     let new_balance: u64 = current_balance - amount;
    //     Mapping::set(balances, wallet_address_hashed_to_field, new_balance);

    //     Mapping::remove(transfers_status, transfer_id);
    //     transfer_function.await();
    // }
}
