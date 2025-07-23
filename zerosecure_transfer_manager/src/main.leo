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
import zero_wallet_manager_v7.aleo;

program zero_transfer_manager_v7.aleo {

    const MAX_OWNERS: u8 = 8u8;
    const ZERO_ADDRESS: address = aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc;
    const CREDITS_RESERVED_TOKEN_ID: field = 3443843282313283355522573239085696902919850365217539366784739393210722344986field;

    record ConfirmTransferTicket {
        owner: address,
        wallet_address: address,
        token_id: field,
        to: address,
        amount: u128,
        transfer_id: field,
        threshold: u8,
    }

    record ExecuteTransferTicket {
        owner: address,
        wallet_address: address,
        token_id: field,
        to: address,
        amount: u128,
        transfer_id: field,
        threshold: u8,
    }

    struct TransferStatus {
        confirmations: u8,
    }

    struct BalanceKey {
        wallet_address: address,
        token_id: field,
    }

    mapping transfers_status: field => TransferStatus; // transfer_id => TransferStatus;
    mapping balances: field => u128; // hash_to_field(BalanceKey) => u128;

    /**
     * Deposit tokens to the wallet (should not be used because it reveals the depositor)
     * @param wallet_address The address of the wallet
     * @param token_id The token id
     * @param amount The amount to deposit
     * @return Future The future of the deposit (to update the balance)
     */
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

    /**
     * Deposit tokens to the wallet (should be used instead of deposit_token_public)
     * @param wallet_address The address of the wallet
     * @param token_id The token id
     * @param amount The amount to deposit
     * @param credits The token record to deposit
     * @return Future The future of the deposit (to update the balance)
     */
    async transition deposit_token_private(wallet_address: address, amount: u128, credits: token_registry.aleo/Token) -> (token_registry.aleo/Token, Future) {
        let balance_key: BalanceKey = BalanceKey {
            wallet_address: wallet_address,
            token_id: credits.token_id,
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

    /**
     * Deposit aleo credits to the wallet (should not be used because it reveals the depositor)
     * @param wallet_address The address of the wallet
     * @param amount The amount to deposit
     * @return Future The future of the deposit (to update the balance)
     */
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

    /**
     * Deposit aleo credits to the wallet (should be used instead of deposit_aleo_public)
     * @param wallet_address The address of the wallet
     * @param amount The amount to deposit
     * @param credits The credits record to deposit
     * @return Future The future of the deposit (to update the balance)
     */
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

    /**
     * Create a new transfer
     * @param wallet The wallet record
     * @param token_id The token id (if it is aleo credits, use CREDITS_RESERVED_TOKEN_ID)
     * @param to The address to transfer to
     * @param amount The amount to transfer
     * @param transfer_id The transfer id
     * @return The new wallet record, the execute transfer ticket, and the confirm transfer tickets
     */
    async transition create_transfer(wallet: zero_wallet_manager_v7.aleo/Wallet, token_id: field, to: address, amount: u128, transfer_id: field) -> (zero_wallet_manager_v7.aleo/Wallet, ExecuteTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, Future) {
        let confirm_transfer_ticket_1: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[0u8] ? ZERO_ADDRESS : wallet.owners[0u8],
            wallet_address: wallet.wallet_address,
            token_id: token_id,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_2: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[1u8] ? ZERO_ADDRESS : wallet.owners[1u8],
            wallet_address: wallet.wallet_address,
            token_id: token_id,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_3: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[2u8] ? ZERO_ADDRESS : wallet.owners[2u8],
            wallet_address: wallet.wallet_address,
            token_id: token_id,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_4: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[3u8] ? ZERO_ADDRESS : wallet.owners[3u8],
            wallet_address: wallet.wallet_address,
            token_id: token_id,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_5: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[4u8] ? ZERO_ADDRESS : wallet.owners[4u8],
            wallet_address: wallet.wallet_address,
            token_id: token_id,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_6: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[5u8] ? ZERO_ADDRESS : wallet.owners[5u8],
            wallet_address: wallet.wallet_address,
            token_id: token_id,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_7: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[6u8] ? ZERO_ADDRESS : wallet.owners[6u8],
            wallet_address: wallet.wallet_address,
            token_id: token_id,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_8: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[7u8] ? ZERO_ADDRESS : wallet.owners[7u8],
            wallet_address: wallet.wallet_address,
            token_id: token_id,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let execute_transfer_ticket: ExecuteTransferTicket = ExecuteTransferTicket {
            owner: wallet.owner,
            wallet_address: wallet.wallet_address,
            token_id: token_id,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let balance_key: BalanceKey = BalanceKey {
            wallet_address: wallet.wallet_address,
            token_id: token_id,
        };
        let balance_key_hashed: field = BHP256::hash_to_field(balance_key);
        let wallet_address_hashed_to_field: field = BHP256::hash_to_field(wallet.wallet_address);
        let new_wallet: zero_wallet_manager_v7.aleo/Wallet = zero_wallet_manager_v7.aleo/refresh_wallet_record(wallet);

        return (new_wallet, execute_transfer_ticket, confirm_transfer_ticket_1, confirm_transfer_ticket_2, confirm_transfer_ticket_3, confirm_transfer_ticket_4, confirm_transfer_ticket_5, confirm_transfer_ticket_6, confirm_transfer_ticket_7, confirm_transfer_ticket_8, finalize_create_transfer(wallet_address_hashed_to_field, balance_key_hashed, transfer_id, amount, wallet.sequence));
    }

    async function finalize_create_transfer(wallet_address_hashed_to_field: field, balance_key_hashed: field, transfer_id: field, amount: u128, sequence: u64) {
        // check if the balance is enough
        let current_balance: u128 = Mapping::get(balances, balance_key_hashed);
        assert_eq(current_balance >= amount, true);

        // check if the transfer_id is unique
        assert_eq(Mapping::contains(transfers_status, transfer_id), false);

        // check if the sequence is latest
        let onchain_wallet_sequence: u64 = Mapping::get(zero_wallet_manager_v7.aleo/wallet_sequence, wallet_address_hashed_to_field);
        assert_eq(onchain_wallet_sequence == sequence, true);

        Mapping::set(transfers_status, transfer_id, TransferStatus {
            confirmations: 1u8,
        });
    }

    /**
     * Confirm a transfer
     * @param confirm_transfer_ticket The confirm transfer ticket
     * @return The execute transfer ticket and the future of the confirmation
     */
    async transition confirm_transfer(confirm_transfer_ticket: ConfirmTransferTicket) -> (ExecuteTransferTicket, Future) {
        let execute_transfer_ticket: ExecuteTransferTicket = ExecuteTransferTicket {
            owner: confirm_transfer_ticket.owner,
            wallet_address: confirm_transfer_ticket.wallet_address,
            token_id: confirm_transfer_ticket.token_id,
            to: confirm_transfer_ticket.to,
            amount: confirm_transfer_ticket.amount,
            transfer_id: confirm_transfer_ticket.transfer_id,
            threshold: confirm_transfer_ticket.threshold,
        };

        return (execute_transfer_ticket, finalize_confirm_transfer(confirm_transfer_ticket.transfer_id));
    }

    async function finalize_confirm_transfer(transfer_id: field) {
        let transfer_status: TransferStatus = Mapping::get(transfers_status, transfer_id);
        Mapping::set(transfers_status, transfer_id, TransferStatus {
            confirmations: transfer_status.confirmations + 1u8,
        });
    }

    /**
     * Execute a aleo transfer (token_id should be CREDITS_RESERVED_TOKEN_ID)
     * @param execute_transfer_ticket The execute transfer ticket
     * @return The receiver credits and the future of the execution
     */
    async transition execute_aleo_transfer(execute_transfer_ticket: ExecuteTransferTicket) -> (credits.aleo/credits, Future) {
        // check if token_id is aleo credits
        assert_eq(execute_transfer_ticket.token_id, CREDITS_RESERVED_TOKEN_ID);

        let balance_key: BalanceKey = BalanceKey {
            wallet_address: execute_transfer_ticket.wallet_address,
            token_id: execute_transfer_ticket.token_id,
        };
        let balance_key_hashed: field = BHP256::hash_to_field(balance_key);
        let (receiver_credits, transfer_function): (credits.aleo/credits, Future) = credits.aleo/transfer_public_to_private(execute_transfer_ticket.to, execute_transfer_ticket.amount as u64);
        
        return (receiver_credits, finalize_execute_aleo_transfer(balance_key_hashed, execute_transfer_ticket.transfer_id, execute_transfer_ticket.threshold, execute_transfer_ticket.amount, transfer_function));
    }

    async function finalize_execute_aleo_transfer(balance_key_hashed: field, transfer_id: field, threshold: u8, amount: u128, transfer_function: Future) {
        // check if the transfer has enough confirmations
        let onchain_transfer_status: TransferStatus = Mapping::get(transfers_status, transfer_id);
        assert_eq(onchain_transfer_status.confirmations >= threshold, true);

        // check if the wallet has enough balance
        let current_balance: u128 = Mapping::get(balances, balance_key_hashed);
        assert_eq(current_balance >= amount, true);

        // set the new balance
        let new_balance: u128 = current_balance - amount;
        Mapping::set(balances, balance_key_hashed, new_balance);

        Mapping::remove(transfers_status, transfer_id);
        transfer_function.await();
    }

    /**
     * Execute a token transfer (token_id should not be CREDITS_RESERVED_TOKEN_ID)
     * @param execute_transfer_ticket The execute transfer ticket
     * @param external_authorization_required If the external authorization is required
     * @return The receiver credits and the future of the execution
     */
    async transition execute_token_transfer(execute_transfer_ticket: ExecuteTransferTicket, external_authorization_required: bool) -> (token_registry.aleo/Token, Future) {
        // check if token_id is NOT aleo credits
        assert_neq(execute_transfer_ticket.token_id, CREDITS_RESERVED_TOKEN_ID);

       let balance_key: BalanceKey = BalanceKey {
            wallet_address: execute_transfer_ticket.wallet_address,
            token_id: execute_transfer_ticket.token_id,
        };
        let balance_key_hashed: field = BHP256::hash_to_field(balance_key);
        let (receiver_credits, transfer_function): (token_registry.aleo/Token, Future) = token_registry.aleo/transfer_public_to_private(execute_transfer_ticket.token_id, execute_transfer_ticket.to, execute_transfer_ticket.amount, external_authorization_required);
        
        return (receiver_credits, finalize_execute_token_transfer(balance_key_hashed, execute_transfer_ticket.transfer_id, execute_transfer_ticket.threshold, execute_transfer_ticket.amount, transfer_function));
    }

    async function finalize_execute_token_transfer(balance_key_hashed: field, transfer_id: field, threshold: u8, amount: u128, transfer_function: Future) {
        // check if the transfer has enough confirmations
        let onchain_transfer_status: TransferStatus = Mapping::get(transfers_status, transfer_id);
        assert_eq(onchain_transfer_status.confirmations >= threshold, true);

        // check if the wallet has enough balance
        let current_balance: u128 = Mapping::get(balances, balance_key_hashed);
        assert_eq(current_balance >= amount, true);

        // set the new balance
        let new_balance: u128 = current_balance - amount;
        Mapping::set(balances, balance_key_hashed, new_balance);

        Mapping::remove(transfers_status, transfer_id);
        transfer_function.await();
    }

    ////////////// Test Helper Functions //////////////
    // WARNING: These functions are used for testing purposes only and should not be used in production code!!!!!!.
    
    transition mint_ConfirmTransferTicket (
        owner: address,
        wallet_address: address,
        token_id: field,
        to: address,
        amount: u128,
        transfer_id: field,
        threshold: u8,
    ) -> ConfirmTransferTicket {
        return ConfirmTransferTicket {
            owner,
            wallet_address,
            token_id,
            to,
            amount,
            transfer_id,
            threshold,
        };
    }

    transition mint_ExecuteTransferTicket (
        owner: address,
        wallet_address: address,
        token_id: field,
        to: address,
        amount: u128,
        transfer_id: field,
        threshold: u8,
    ) -> ExecuteTransferTicket {
        return ExecuteTransferTicket {
            owner,
            wallet_address,
            token_id,
            to,
            amount,
            transfer_id,
            threshold,
        };
    }
}
