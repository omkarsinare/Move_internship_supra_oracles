resource struct ObjectCore {
    owner: address
}

resource struct Wallet {
    amount: u64,
    owner: address
}


resource struct Aptos {
    name: string,
    proposer: address,
    upvotes: u64
}
public let MAX_UPVOTES: u64 = 5;
public let UPVOTE_PRICE: u64 = 10;
public var ongoing_round: u64 = 0;


public fun get_wallet(amount: u64): Wallet {
    let participant: address = get_sender();
    let wallet: Wallet = Wallet {
        amount: amount,
        owner: participant
    };
    return wallet;
}


public fun create_proposal(name: string): Aptos {
    let proposer: address = get_sender();
    let proposal: Aptos = Aptos {
        name: name,
        proposer: proposer,
        upvotes: 0
    };
    return proposal;
}


public fun upvote_proposal(proposal: &Aptos, amount: u64) {
    let participant: address = get_sender();
    assert(move(proposal.proposer != participant), 1); // Can't upvote own proposal
    assert(move(amount >= UPVOTE_PRICE), 2); // Validate the amount

    
    let wallet: &mut Wallet;
    move_to(participant, wallet);
    wallet.amount = move(wallet.amount - UPVOTE_PRICE);

    proposal.upvotes = move(proposal.upvotes + 1);

    
    if proposal.upvotes == MAX_UPVOTES {
        
        handle_end_of_round(proposal.proposer);
    }
}


public fun handle_end_of_round(winner: address) {
    let proposals: vector<Aptos> = Vector<Aptos>(3);
    

    
    for proposal in &proposals {
        
    }

    
    let total_reward: u64 = MAX_UPVOTES * UPVOTE_PRICE;

    for proposal in &proposals {
        if proposal.proposer == winner {
            
            let winner_wallet: &mut Wallet;
            move_to(winner, winner_wallet);
            winner_wallet.amount = move(winner_wallet.amount + total_reward);
        } else {
            
            let proposer_wallet: &mut Wallet;
            move_to(proposal.proposer, proposer_wallet);
            proposer_wallet.amount = move(proposer_wallet.amount + total_reward / 2);
        }
    }

   
    let dapp_wallet: &mut Wallet;
    
    move_to(0x1, dapp_wallet);
    dapp_wallet.amount = move(dapp_wallet.amount + total_reward / 2);

    
    ongoing_round = move(ongoing_round + 1);
}
