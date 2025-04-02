// The 'zerosecure_governance_manager' program.
program zerosecure_governance_manager.aleo {
    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }
}
