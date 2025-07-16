import zerosecure_transfer_managerv5.aleo;
import credits.aleo;
import token_registry.aleo;

program test_transfer_manager.aleo {
    // This program is a test suite for the transfer manager.

    const SELF: address = self.address;
    const TOKEN_ID: field = 7777field;
    const CREDITS_RESERVED_TOKEN_ID: field = 3443843282313283355522573239085696902919850365217539366784739393210722344986field;

    struct TransferStatus {
        confirmations: u8,
    }

    struct Balance {
        token_id: field,
        account: address,
        balance: u128,
        authorized_until: u32
    }

    struct TokenOwner {
        account: address,
        token_id: field
    }

    @test
    transition init () -> () {
    
    }

    script get_multi_wallet_balance (w: address, token_id: field) -> u128 {
        let balance_key: BalanceKey = BalanceKey {
            wallet_address: multi_wallet.aleo,
            token_id: CREDITS_RESERVED_TOKEN_ID,
        };

        let current_balance: u128 = Mapping::get(zerosecure_transfer_managerv5.aleo/balances, BHP256::hash_to_field(balance_key));
        return current_balance;
    }

    script get_aleo_public_balance(w: address) -> u64 {
        return Mapping::get(credits.aleo/account, w);
    }

    @test
    script main() {
        // Give the contract and private key some credits to use.
        Mapping::set(credits.aleo/account, SELF, 1000000u64);
        Mapping::set(credits.aleo/account, self.signer, 1000000u64);
        let deposit_aleo_public_future: Future = zerosecure_transfer_managerv5.aleo/deposit_aleo_public(multi_wallet.aleo, 1u128);
        deposit_aleo_public_future.await();

        assert_eq(get_multi_wallet_balance(multi_wallet.aleo, CREDITS_RESERVED_TOKEN_ID), 1u128);
        assert_eq(get_aleo_public_balance(zerosecure_transfer_managerv5.aleo), 1u64);
        assert_eq(get_aleo_public_balance(self.signer), 1000000u64-1u64);

        // token_registry.aleo/register_token(TOKEN_ID, 0u128, 0u128, 0u8, 1000u128, false, no.aleo).await();
        // assert_eq(Mapping::get(token_registry.aleo/registered_tokens, TOKEN_ID).max_supply, 1000u128);
        // let token_owner: TokenOwner = TokenOwner {
        //     account: self.signer,
        //     token_id: TOKEN_ID
        // };
        // let token_balance = Balance {
        //     token_id: TOKEN_ID,
        //     account: self.signer,
        //     balance: 100u128,
        //     authorized_until: 0u32
        // };
        // Mapping::set(token_registry.aleo/authorized_balances, BHP256::hash_to_field(token_owner), token_balance);
        // zerosecure_transfer_managerv5.aleo/deposit_token_public(multi_wallet.aleo, TOKEN_ID, 1u128).await();

        let transfer_id: field = 1234567890field;
        Mapping::set(zerosecure_transfer_managerv5.aleo/transfers_status, transfer_id, TransferStatus {
            confirmations: 1u8,
        });
        let exe_ticket = zerosecure_transfer_managerv5.aleo/mint_ExecuteTransferTicket(
            SELF,
            multi_wallet.aleo,
            CREDITS_RESERVED_TOKEN_ID,
            self.signer,
            1u128,
            transfer_id,
            1u8,
        );
        let (aleo_credits, f) = zerosecure_transfer_managerv5.aleo/execute_aleo_transfer(exe_ticket);
        f.await();

        assert_eq(get_aleo_public_balance(zerosecure_transfer_managerv5.aleo), 0u64);
    }
}