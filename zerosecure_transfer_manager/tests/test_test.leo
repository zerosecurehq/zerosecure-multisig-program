import credits.aleo;
import token_registry.aleo;

program test_test.aleo {
    @test
    transition init () -> () {
    }

    @test
    script test_record() {
        Mapping::set(credits.aleo/account, self.address, 1000000u64);
        Mapping::set(credits.aleo/account, self.signer, 1000000u64);

        let (credits_record, credits_future): (credits.aleo/credits, Future) = credits.aleo/transfer_public_to_private(self.signer, 1u64);
        credits_future.await();

        // Throw
        //assert_eq(credits_record.microcredits, 1u64);
        //assert_eq(credits_record.owner, self.signer);

        // Throw
        let (c1, c2): (credits.aleo/credits, credits.aleo/credits) = credits.aleo/transfer_private(credits_record, self.signer, 1u64);
    }

    @test 
    script test_token_registry() {
       let init_future: Future = token_registry.aleo/initialize();
       // Throw
       //init_future.await();
       
       let register_future: Future =  token_registry.aleo/register_token(0field, 0u128, 0u128, 0u8, 1000u128, false, no.aleo);
        register_future.await();

        // Ok
        assert_eq(Mapping::get(token_registry.aleo/registered_tokens, 0field).max_supply, 1000u128);
        let mint_token_public_future: Future = token_registry.aleo/mint_public(
            0field,
            self.signer,
            100u128,
            0u32,
        );
        
        // Leo will hang here
        ///mint_token_public_future.await();
    }

}