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

import zerosecure_wallet_manager.aleo;

program zerosecure_transfer_manager.aleo {

    const MAX_OWNERS:u8 = 8u8;
    const ZERO_ADDRESS:address = aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc;
    const CREDITS_RESERVED_TOKEN_ID: field = 3443843282313283355522573239085696902919850365217539366784739393210722344986field;


    record ConfirmTransferTicket {
        owner: address,
        wallet_address: address,
        token_id: field,
        to: address,
        amount: u64,
        transfer_id: field,
        threshold: u8,
    }

    record ExecuteTransferTicket {
        owner: address,
        wallet_address: address,
        token_id: field,
        to: address,
        amount: u64,
        transfer_id: field,
        threshold: u8,
    }

    struct TransferStatus {
        confirmations: u8,
    }

    // transfer_id => TransferStatus;
    mapping transfers_status: field => TransferStatus;

    async transition create_aleo_transfer(wallet: zerosecure_wallet_manager.aleo/Wallet, to: address, amount: u64, transfer_id: field) -> (zerosecure_wallet_manager.aleo/Wallet, ExecuteTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, ConfirmTransferTicket, Future) {
        let confirm_transfer_ticket_1: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[0u8] ? ZERO_ADDRESS : wallet.owners[0u8],
            wallet_address: wallet.wallet_address,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_2: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[1u8] ? ZERO_ADDRESS : wallet.owners[1u8],
            wallet_address: wallet.wallet_address,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_3: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[2u8] ? ZERO_ADDRESS : wallet.owners[2u8],
            wallet_address: wallet.wallet_address,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_4: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[3u8] ? ZERO_ADDRESS : wallet.owners[3u8],
            wallet_address: wallet.wallet_address,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_5: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[4u8] ? ZERO_ADDRESS : wallet.owners[4u8],
            wallet_address: wallet.wallet_address,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_6: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[5u8] ? ZERO_ADDRESS : wallet.owners[5u8],
            wallet_address: wallet.wallet_address,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_7: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[6u8] ? ZERO_ADDRESS : wallet.owners[6u8],
            wallet_address: wallet.wallet_address,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let confirm_transfer_ticket_8: ConfirmTransferTicket = ConfirmTransferTicket {
            owner: wallet.owner == wallet.owners[7u8] ? ZERO_ADDRESS : wallet.owners[7u8],
            wallet_address: wallet.wallet_address,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let execute_transfer_ticket: ExecuteTransferTicket = ExecuteTransferTicket {
            owner: wallet.owner,
            wallet_address: wallet.wallet_address,
            to: to,
            amount: amount,
            transfer_id: transfer_id,
            threshold: wallet.threshold,
        };

        let wallet_address_hashed_to_field: field = BHP256::hash_to_field(wallet.wallet_address);
        // let new_wallet: Wallet = Wallet {
        //     owner: wallet.owner,
        //     wallet_address: wallet.wallet_address,
        //     owners: wallet.owners,
        //     threshold: wallet.threshold,
        // };
        let new_wallet: zerosecure_wallet_manager.aleo/Wallet = zerosecure_wallet_manager.aleo/create_new_wallet(wallet.owner, wallet.wallet_address, wallet.owners, wallet.threshold);

        return (new_wallet, execute_transfer_ticket, confirm_transfer_ticket_1, confirm_transfer_ticket_2, confirm_transfer_ticket_3, confirm_transfer_ticket_4, confirm_transfer_ticket_5, confirm_transfer_ticket_6, confirm_transfer_ticket_7, confirm_transfer_ticket_8, finalize_create_aleo_transfer(wallet_address_hashed_to_field, transfer_id, amount));
    }

    async function finalize_create_aleo_transfer(wallet_address_hashed_to_field: field, transfer_id: field, amount: u64) {
        let current_balance: u64 = Mapping::get(balances, wallet_address_hashed_to_field);
        assert_eq(current_balance >= amount, true);
        assert_eq(Mapping::contains(transfers_status, transfer_id), false);

        let transfer_status: TransferStatus = TransferStatus {
            confirmations: 1u8,
        };
        Mapping::set(transfers_status, transfer_id, transfer_status);
    }
}
